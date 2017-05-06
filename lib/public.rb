require 'json'
require 'jwt'
require 'sinatra/base'
require 'mongoid'
require 'omniauth-twitter'

require 'helpers/jwt_helper'
require 'models/user'
require 'models/feed'

class Public < Sinatra::Base
  include JWTHelper

  ### Sinatra Setup ###
  configure do
    Mongoid.load!('./mongoid.yml')
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']
  end

  before do
    content_type 'application/vnd.api+json'
  end

  use OmniAuth::Builder do
    provider :twitter,
             ENV['TWITTER_CONSUMER_KEY'],
             ENV['TWITTER_CONSUMER_SECRET']
  end

  ### Routes ###
  get '/users' do
    User.last.jsonapi_response
  end

  get '/authenticate' do
    redirect to('/auth/twitter')
  end

  get '/auth/twitter/callback' do
    user = User.where(
      twitter_id: env['omniauth.auth']['uid']
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

    response.headers['Authorization'] = create_jwt_token(
      user.id.to_s,
      user.username
    )
    redirect to(ENV['WEB_SERVICE_URL'])
  end
end
