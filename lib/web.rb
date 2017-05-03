require 'sinatra'
require 'dotenv/load'
require 'mongo'
require 'json/ext' # required for .to_json

configure do
  mongodb_client = Mongo::Client.new(ENV['MONGODB_URI'])
  set :mongo_db, mongodb_client
  enable :sessions
end

helpers do
  def admin?
    session[:admin]
  end
end

### Routes ###
get '/' do
  'Hello World!'
end

get '/collections/?' do
  content_type :json
  settings.mongo_db.database.collection_names.to_json
end

get '/public' do
  "This is the public page - everybody is welcome!"
end

get '/private' do
  halt(401,'Not Authorized') unless admin?
  "This is the private page - members only"
end

get '/login' do
  session[:admin] = true
  "You are now logged in"
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end
