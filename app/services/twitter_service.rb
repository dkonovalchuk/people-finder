class TwitterService

  TWITTER_HOME = "https://twitter.com/"

  # Search via twitter api users/search method for query
  # returns String user's screen name or nil
  #
  def search_user_for(query)
    user = client.user_search(query, include_entities: true).first
    return unless user
    user.screen_name
  end

  # Recent tweets for specified username
  # returns [] if twitter_username not found (nil)
  #
  def recent_tweets_from(username)
    return [] unless username
    tweets = client.user_timeline(username)
    tweets.map { |tweet| tweet_wrapper(tweet) }
  end

  private

  # Hash to wrap tweet
  #
  def tweet_wrapper(tweet)
    {
      content: tweet.text,
      date_tweeted: tweet.created_at,
      tweet_url: tweet.uri.to_s
    }
  end

  # Twitter API client
  #
  def client
    @client ||= Twitter::REST::Client.new do |c|
      c.consumer_key        = config[:consumer_key]
      c.consumer_secret     = config[:consumer_secret]
      c.access_token        = config[:access_token]
      c.access_token_secret = config[:access_token_secret]
    end
  end

  def config
    @config = YAML.load_file(File.join(Rails.root, "config", "twitter.yml")).symbolize_keys!
  end
end
