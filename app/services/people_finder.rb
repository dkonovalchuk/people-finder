# Class which finds company data and twitter data
# for specified email and person's full name
#
class PeopleFinder

  def initialize(email, name = nil)
    @email = email
    @name = name
  end

  # Output result hash/json
  #
  def result
    {
      full_name: @name,
      email_address: @email,
      company: {
        name: company_name,
        website: company_url
      },
      twitter: {
        handle: "@#{twitter_username}",
        recent_tweets: recent_tweets
      },
      news: news
    }
  end

  # Recent tweets for founded twitter_username
  # returns [] if twitter_username not found (nil)
  #
  def recent_tweets
    twitter_service.recent_tweets_from(twitter_username)
  end

  # Company name from company's website title
  # Company website is a first website from search results for domain query
  # returns title's substring before first non world character
  #
  # example
  #   "Intuit: small business, personal finance and tax software".split(/[^\w\s]/).first #=> "Intuit"
  #
  def company_name
    @company_name ||= begin
      first_result = search_for(domain).first
      return unless first_result
      first_result.title.split(/[^\w\s]/).first
    end
  end

  # Returns first website's url from search results for domain
  #
  def company_url
    first_result = search_for(domain).first
    return unless first_result
    first_result.link
  end

  # Recent news about company
  #
  def news
    search = Google::Search::News.new { |search| search.query = domain }
    search.response.first(10).map { |news| news_wrapper(news) }
  end

  private

  # Hash to wrap news
  #
  def news_wrapper(news)
    {
      title: news.title,
      date_published: news.published.to_s,
      source: news.publisher.capitalize,
      source_url: news.uri
    }
  end

  # Person's twitter username
  # returns String or nil if nothing found
  #
  # Searches for twitter_account_query throught three sources
  # At first search google via google-search-search api
  # if nothing was found search google via httparty get request
  # else search for username via twitter api's users/search method
  #
  def twitter_username
    @twitter_username ||= begin
      twitter_username_from_custom_search || \
      websearcher.screen_name || \
      twitter_username_from_twitter_search
    end
  end

  # Domain part from person's email
  # Usually it's almost a company name
  # Uses to search via google for company name
  #
  def domain
    @domain ||= @email.match(/@(.+)\./).to_a.last
  end

  def twitter_username_from_custom_search
    results = search_for(twitter_account_query)
    return unless results.present?

    result = results.find { |r| r.link.start_with?(TwitterService::TWITTER_HOME) }
    return unless result

    result.link.gsub(TwitterService::TWITTER_HOME, "").split(/[^\w\s]/).first
  end

  # Search for specified query via GoogleSearchService
  #
  def search_for(query)
    service = GoogleSearchService.new(query)
    service.results
  end

  # Call to TwitterService's search_user_for
  #
  def twitter_username_from_twitter_search
    twitter_service.search_user_for("#{@name} #{company_name}")
  end

  # TwitterService instance
  #
  def twitter_service
    @twitter_service ||= TwitterService.new
  end

  # GoogleWebSearcher instance
  #
  def websearcher
    @websearcher ||= GoogleWebSearcher.new(twitter_account_query)
  end

  # Query to search person's twitter
  #
  # example
  #    "Twitter Karin Abbott CSG International"
  #
  def twitter_account_query
    "Twitter #{@name} #{company_name}"
  end
end
