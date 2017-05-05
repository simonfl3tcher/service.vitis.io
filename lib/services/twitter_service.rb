require 'twitter'

class TwitterService
  LIMIT=5

  def initialize(user:, feed:)
    @feed = feed
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = user.token
      config.access_token_secret = user.secret
    end
  end

  def run
    case @feed.type
    when "timeline"
      @client.home_timeline.take(LIMIT)
    when "search"
      @client.search(
        @feed.search_parameter,
        result_type: "recent",
        lang: "en",
        include_rts: false
      ).take(LIMIT)
    end
  end
end
