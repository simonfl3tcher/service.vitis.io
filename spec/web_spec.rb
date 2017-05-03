ENV['RACK_ENV'] = 'test'

require 'web'  # <-- your sinatra app
require 'rspec'
require 'rack/test'

describe 'The HelloWorld App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says Hello World!" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello World!')
  end
end
