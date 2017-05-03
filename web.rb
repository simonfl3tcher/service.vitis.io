require 'sinatra'
require 'dotenv/load'
require 'mongo'
require 'json/ext' # required for .to_json

configure do
  mongodb_client = Mongo::Client.new(ENV['MONGODB_URI'])
  set :mongo_db, mongodb_client
end

### Routes ###
get '/' do
  'Hello Simon Fletcher!'
end

get '/collections/?' do
  content_type :json
  settings.mongo_db.database.collection_names.to_json
end
