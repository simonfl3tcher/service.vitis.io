require 'omniauth-twitter'
OmniAuth.config.test_mode = true

describe Public do

  describe "GET /authenticate" do
    it "should redirect to /auth/twitter which is handled by OmniAuth" do
      get "/authenticate"

      expect(last_response.location).to match("http://example.org/auth/twitter")
    end
  end

  describe "GET /auth/twitter/callback" do
    before(:each) do
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
        :provider => 'twitter',
        :uid => '12345',
        :credentials => {
          :token  => "123",
          :secret => "456"
        },
        :info => {
          :name     => "Simon Fletcher",
          :username => "simonfl3tcher",
          :image    => "http://simonfl3tcher.com"
        }
      })
    end

    it "should create a user on successful return" do

      expect(User.count).to eq(0)

      get '/auth/twitter/callback'

      expect(User.count).to eq(1)

      user = User.last

      expect(user.twitter_id).to eq("12345")
      expect(user.token).to eq("123")
      expect(user.secret).to eq("456")
      expect(user.username).to eq("simonfl3tcher")
      expect(user.name).to eq("Simon Fletcher")
      expect(user.image_url).to eq("http://simonfl3tcher.com")
    end

    it "should create a user with a default timeline feed" do
      get '/auth/twitter/callback'
      user = User.last

      expect(user.feeds.count).to eq(1)
      expect(user.feeds.first.name).to eq('Timeline')
      expect(user.feeds.first.type).to eq('timeline')
    end

    it "should redirect to web service with JWT" do
      get '/auth/twitter/callback'

      user = User.last
      token = create_jwt_token(user.id.to_s, user.username)

      expect(last_response.location).to eq("http://example.org/")
      expect(last_response.headers["Authorization"]).to eq(token)
    end

    after(:each) do
      OmniAuth.config.mock_auth[:twitter] = nil
    end
  end
end
