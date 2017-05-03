ENV['RACK_ENV'] = 'test'

require 'web'
require 'rspec'
require 'rack/test'

describe 'The web service' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    @user = User.create(
      twitter_id: "134324123",
      name: "Andy Blogg",
      image_url: "http://simonfl3tcher.com"
    )
    @user.feeds << Feed.new(:name => "YOLO")
  end

  describe "POST /users" do
    before(:all) do
      @params = {
        user: {
          twitter_id: "1231241",
          name: "Simon Fletcher",
          image_url: "http://simonfl3tcher.com"
        }
      }
    end

    it "Creates user if it doesn't exist" do
      post '/users', @params, { format: 'json' }
      expect(last_response.content_type).to eq("application/json;charset=utf-8")
      expect(last_response.body).to be_a(String)
    end

    it "does not create user if it already exist" do
      @user = User.create!(@params[:user])

      post '/users', @params, { format: 'json' }

      expect(last_response.content_type).to eq("application/json;charset=utf-8")
      expect(JSON.parse(last_response.body)["id"]).to eq(@user.id.to_s)
    end
  end

  describe "GET /users/:id/feeds" do
    it "should return all the feeds for a user" do
      get "/users/#{@user.id}/feeds"

      expect(last_response.content_type).to eq("application/json;charset=utf-8")
      expect(JSON.parse(last_response.body)[0]["name"]).to eq("YOLO")
    end
  end

  describe "GET /users/:id/feeds/:feed_id" do
    it "should return the single feed for the user" do
      get "/users/#{@user.id}/feeds/#{@user.feeds.first.id}"

      expect(last_response.content_type).to eq("application/json;charset=utf-8")
      expect(JSON.parse(last_response.body)["name"]).to eq("YOLO")
    end
  end

  describe "PUT /users/:id/feeds/:feed_id" do
    it "should update a single feed for the user" do
      put "/users/#{@user.id}/feeds/#{@user.feeds.first.id}", {:name => "TOLO"}

      expect(last_response.content_type).to eq("application/json;charset=utf-8")
      expect(JSON.parse(last_response.body)["name"]).to eq("TOLO")
    end
  end

  describe "DELETE /users/:id/feeds/:feed_id" do
    it "should delete a single feed for the user" do
      @user.feeds << Feed.new(:name => "TOLO")

      expect(@user.feeds.count).to eq(2)

      delete "/users/#{@user.id}/feeds/#{@user.feeds.first.id}"

      expect(@user.reload.feeds.count).to eq(1)
      expect(last_response.status).to eq(204)
    end
  end
end
