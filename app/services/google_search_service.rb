require "google/api_client"

class GoogleSearchService

  def initialize(query)
    @query = query
  end

  def results
    search_for_query rescue []
  end

  private

  def search_for_query
    response = client.execute(
      api_method: service.cse.list,
      parameters: {
        q: @query,
        key: config[:api_key],
        cx: config[:cx]
      }
    )

    return [] unless response.data
    response.data.items
  end

  def service
    @service ||= client.discovered_api("customsearch")
  end

  def client
    @client ||= Google::APIClient.new(key: config[:api_key], authorization: nil)
  end

  def config
    @config = YAML.load_file(File.join(Rails.root, "config", "custom-search.yml")).symbolize_keys!
  end
end
