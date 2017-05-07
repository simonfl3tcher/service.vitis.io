require 'json'
require 'jwt'
require 'sinatra/base'
require 'mongoid'
require 'omniauth-twitter'

require_relative 'models/user'
require_relative 'models/feed'
require_relative 'services/twitter_service'
require_relative 'services/jwt_auth'
require_relative 'helpers/jwt_helper'

class Api < Sinatra::Base
  include JWTHelper
  use JwtAuth

  ### Sinatra Setup ###
  configure do
    Mongoid.load!('./mongoid.yml')
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']
  end

  before do
    content_type 'application/vnd.api+json'
    headers["Access-Control-Allow-Origin"]  = ENV['WEB_SERVICE_URL']
    headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept, Authorization"
    headers["Access-Control-Allow-Credentials"] = "true"
    headers["Access-Control-Allow-Methods"] = %w[
      POST
      PUT
      DELETE
      GET
      OPTIONS
    ]
  end

  ### Routes ###
  options '*' do
    halt 200
  end

  get '/users/:id' do
    @user = User.find(params[:id])
    process_request(request, 'view_feed', @user) do |_req|
      if @user
        status 200
        @user.jsonapi_response
      else
        status 404
      end
    end
  end

  get '/users/:id/feeds/:feed_id' do
    @user = User.find(params[:id])
    process_request(request, 'view_feed', @user) do |_req|
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
    process_request(request, 'create_feed', @user) do |_req|
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
          title: 'Feed failed to be created',
          errors: @feed.errors
        )
      end
    end
  end

  put '/users/:id/feeds/:feed_id' do
    @user = User.find(params[:id])
    process_request(request, 'update_feed', @user) do |_req|
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
          title:  'Feed failed to be updated',
          errors: @feed.errors
        )
      end
    end
  end

  delete '/users/:id/feeds/:feed_id' do
    @user = User.find(params[:id])
    process_request(request, 'delete_feed', @user) do |_req|
      feed = @user.feeds.where(id: params[:feed_id])

      if !feed.present?
        status 404
      elsif feed.destroy
        status 204
      end
    end
  end

  ### Methods ###
  def error_status_response(title: 'Failed', errors: [])
    {
      status: 400,
      title:  title,
      errors: errors
    }.to_json
  end
end
