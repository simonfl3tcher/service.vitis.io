require 'sinatra'
require 'mongoid'
require 'omniauth-twitter'
require 'jwt'

configure do
  Mongoid.load!("./mongoid.yml")
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
end

before do
  content_type 'application/vnd.api+json'
end

use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end

### Models ###
require_relative 'models/user'
require_relative 'models/feed'

### Services ###
require_relative 'services/twitter_service'
require_relative 'services/jwt_auth'

use JwtAuth

### HTML Routes ###
get '/users' do
  User.last.jsonapi_response
end

get '/authenticate' do
  redirect to("/auth/twitter")
end

get '/auth/twitter/callback' do
  user = User.where(
    twitter_id: env['omniauth.auth']["uid"]
  ).first

  unless user.present?
    user = User.create!(
      twitter_id: env['omniauth.auth']['uid'],
      token:      env['omniauth.auth']['credentials']['token'],
      secret:     env['omniauth.auth']['credentials']['secret'],
      name:       env['omniauth.auth']['info']['name'],
      username:   env['omniauth.auth']['info']['username'],
      image_url:  env['omniauth.auth']['info']['image'],
      feeds_attributes: [
        {
          name: 'Timeline',
          type: 'timeline'
        }
      ]
    )
  end

  redirect to("#{ENV['WEB_SERVICE_URL']}?user#{token(user.id.to_s, user.username)}")
end

### JSON Routes ###
get '/users/:id/feeds/:feed_id' do
  @user = User.find(params[:id])
  process_request(request, 'view_feed', @user) do |req|
    @feed = @user.feeds.where(id: params[:feed_id]).first

    if @feed
      status 200
      TwitterService.new(
        user: @user,
        feed: @feed
      ).run.to_json
    else
      status 404
    end
  end
end

post '/users/:id/feeds' do
  @user = User.find(params[:id])
  @feed = Feed.new(
    name:             params[:feed][:name],
    type:             params[:feed][:type],
    search_parameter: params[:feed][:search_parameter],
    users:            params[:feed][:users]
  )
  @user.feeds << @feed

  if @user.save
    status 201
    @feed.jsonapi_response
  else
    status 400
    error_status_response(
      title: "Feed failed to be created",
      errors: @feed.errors
    )
  end
end


put '/users/:id/feeds/:feed_id' do
  @user = User.find(params[:id])
  @feed = @user.feeds.where(id: params[:feed_id]).first

  update_params = {
    name:             params[:feed][:name],
    type:             params[:feed][:type],
    search_parameter: params[:feed][:search_parameter],
    users:            params[:feed][:users]
  }

  if !@feed.present?
    status 404
  elsif @feed.update(update_params)
    status 200
    @feed.jsonapi_response
  else
    status 400
    error_status_response(
      title: "Feed failed to be updated",
      errors: @feed.errors
    )
  end
end

delete '/users/:id/feeds/:feed_id' do
  @user = User.find(params[:id])
  feed = @user.feeds.where(id: params[:feed_id])

  if !feed.present?
    status 404
  elsif feed.destroy
    status 204
  end
end

def error_status_response(title: "Failed", errors: [])
  {
    status: 400,
    title: title,
    errors: errors
  }.to_json
end

def token(user_id, username)
  JWT.encode payload(user_id, username), ENV['JWT_SECRET'], 'HS256'
end

def payload(user_id, username)
  {
    exp: Time.now.to_i + 60 * 60,
    iat: Time.now.to_i,
    iss: ENV['JWT_ISSUER'],
    scopes: ['create_feed', 'update_feed', 'delete_feed', 'view_feed'],
    user: {
      id: user_id,
      username: username
    }
  }
end

def process_request(req, scope, potential_user)
  scopes, user = req.env.values_at :scopes, :user
  username = user['username']
  user_id  = user['id']

  if scopes.include?(scope) && potential_user.id.to_s == user_id && potential_user.username == username
    yield req
  else
    status 403
  end
end
