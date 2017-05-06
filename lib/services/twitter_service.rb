require 'twitter'

class TwitterService
  LIMIT = 5

  def initialize(user:, feed:)
    @feed = feed
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = user.token
      config.access_token_secret = user.secret
    end
  end

  def run
    case @feed.type
    when 'timeline'
      list_tweets_from_timeline
    when 'search'
      list_tweets_from_search
    when 'list'
      list_tweets_from_users
    end
  end

  private

  def list_tweets_from_timeline
    @client.home_timeline.take(LIMIT)
  end

  def list_tweets_from_search
    @client.search(
      @feed.search_parameter,
      result_type:  'recent',
      lang:         'en',
      include_rts:  false
    ).take(LIMIT)
  end

  def list_tweets_from_users
    @feed.users.flat_map do |user|
      get_top_tweets_by_user(user)
      # FIXME: limit this to the top LIMIT tweets by these users
    end
  end

  def get_top_tweets_by_user(user)
    @client.user_timeline(user).take(LIMIT)
  end
end
