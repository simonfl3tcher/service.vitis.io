require 'sinatra'
require 'dotenv/load'
require 'mongo'
require 'mongoid'
require 'json/ext'

configure do
  Mongoid.load!("./mongoid.yml")
end

before do
  content_type 'application/vnd.api+json'
end

### Models ###
require_relative 'models/user'
require_relative 'models/feed'

### Routes ###
post '/users' do
  @user = User.find_or_create_by(
    :twitter_id   => params[:user][:twitter_id],
    :name         => params[:user][:name],
    :image_url    => params[:user][:image_url],
  )

  if @user.valid?
    status 201
    @user.jsonapi_response
  else
    status 400
    error_status_response(
      title: "User failed to be created",
      errors: @user.errors
    )
  end
end

get '/users/:id/feeds/:feed_id' do
  @user = User.find(params[:id])
  @feed = @user.feeds.where(id: params[:feed_id]).first

  if @feed
    status 200
    @feed.jsonapi_response
  else
    status 404
  end
end

post '/users/:id/feeds' do
  @user = User.find(params[:id])
  @feed = Feed.new(:name => params[:name])
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

  if !@feed.present?
    status 404
  elsif @feed.update(:name => params[:name])
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
