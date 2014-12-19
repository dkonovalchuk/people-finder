# Class to search for twitter's username via google
# Uses httparty gem
#
class GoogleWebSearcher

  SEARCH_URL = "https://www.google.com/search?"

  def initialize(query)
    # Query url
    # example
    #   "https://www.google.com/search?q=Twitter+Karin+Abbott+CSG+International"
    #
    @query = "#{SEARCH_URL}#{query.to_query("q")}"
  end

  # Person's twitter username like 'aaronbev'
  # Looking for url which starts with "https://twitter.com/"
  # If found returns twitter's username from this link
  #
  # example
  #   "https://twitter.com/aaronbev/status/263271458518740992".gsub("https://twitter.com/", "").split(/[^\w\s]/).first \
  #      #=> aaronbev
  #
  def screen_name
    link = links.find { |l| l.start_with?("https://twitter.com/") }
    return unless link
    link.gsub("https://twitter.com/", "").split(/[^\w\s]/).first
  end

  private

  # Google search's links are h3 tags with r class with a tag inside
  # a's href attribute starts with /url?q= , so remove this part for each link
  #
  def links
    html.css("h3.r a").map { |l| l["href"].gsub("/url?q=", "") }
  end

  # HTTParty's response for query wrapped as Nokogiri::HTML
  #
  def html
    Nokogiri::HTML(HTTParty.get(@query))
  end
end