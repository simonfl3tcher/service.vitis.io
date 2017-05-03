require 'sinatra'
require 'dotenv/load'
require 'mongo'
require 'mongoid'
require 'json/ext'

configure do
  Mongoid.load!("./mongoid.yml")
end

### Routes ###
post '/users' do
  content_type :json
  @user = User.find_or_create_by!(
    :twitter_id => params[:user][:twitter_id],
    :name =>  params[:user][:name],
    :image_url => params[:user][:image_url],
  )

  status 201
  {id: @user.id.to_s }.to_json
end

get '/users/:id/feeds' do
  content_type :json
  @user = User.find(params[:id])
  status 200
  @user.feeds.to_json
end

post '/users/:id/feeds' do
  content_type :json
  @user = User.find(params[:id])
  @user.feeds << Feed.new(:name => params[:name])
  @user.save

  status 201
  @user.to_json
end

get '/users/:id/feeds/:feed_id' do
  content_type :json
  @user = User.find(params[:id])

  status 200
  @user.feeds.find(params[:feed_id]).to_json
end

put '/users/:id/feeds/:feed_id' do
  content_type :json
  @user = User.find(params[:id])
  feed = @user.feeds.find(params[:feed_id])
  feed.update(
    :name => params[:name]
  )

  status 200
  feed.to_json
end

delete '/users/:id/feeds/:feed_id' do
  content_type :json
  @user = User.find(params[:id])
  @user.feeds.find(params[:feed_id]).destroy

  status 204
end

class Feed
  include Mongoid::Document
  field :name, type: String
  embedded_in :user
end

class User
  include Mongoid::Document

  field :twitter_id,    type: String
  field :name,          type: String
  field :image_url,     type: String

  embeds_many :feeds
  accepts_nested_attributes_for :feeds
end
