require 'sinatra'
require 'dotenv/load'
require 'mongo'
require 'json/ext' # required for .to_json

configure do
  db = Mongo::Client.new([ ENV['MONGODB_URI'] ], :database => 'vitis')
  set :mongo_db, db[:vitis]
end

### Routes ###
get '/' do
  'Hello Simon Fletcher!'
end

get '/collections/?' do
  content_type :json
  settings.mongo_db.database.collection_names.to_json
end
