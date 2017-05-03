require 'sinatra'
require 'dotenv/load'

### Routes ###
get '/health' do
  'Hello world!'
end
