class Loggly::RetriveService
  SEARCH_URL = 'https://aboutmedia.loggly.com/apiv2/search?'
  EVENT_URL='https://aboutmedia.loggly.com/apiv2/events?rsid='
  EVENT_DIRECT_URI='https://aboutmedia.loggly.com/apiv2/events/iterate?'
  API_TOKEN = '5f4cec61-b124-4da8-bfea-637da2e54c83'

  # superbet 17/02
  def initialize(campaign = '', creative = '')
    @campaign = campaign
    @creative = creative
    @results = []
  end

  attr_reader :campaign, :creative, :results

  def net_request(url)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "bearer #{API_TOKEN}"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response
  end

  def fetch_data
    binding.pry
    url_fetch
    return @results
  end

  def url_fetch(next_page_url = nil)
    final_url = next_page_url || event_url
    response = net_request(final_url)

    return unless response.code == "200"
    body = JSON.parse(response.body)

    last_time = body['events'].last['timestamp']
    p Time.at(last_time/1000)

    body['events'].each do |e|
      event = e['event']['json']
      timestamp = Time.at(e['timestamp']/1000)
      event['timestamp'] = timestamp
      @results.push(event) if event['campaign'].eql?('bridgestone')
    end
    # @results.concat(body['events'].map{|e| e['event']['json']})

    return if body['next'].nil?
    url_fetch(body['next'])
  end

  def url_fetch_custom(next_page_url = nil)
    final_url = next_page_url || event_url
    response = net_request(final_url)

    return unless response.code == "200"
    body = JSON.parse(response.body)

    last_time = body['events'].last['timestamp']
    p Time.at(last_time/1000)

    body['events'].each do |e|
      event = e['event']['json']
      if event['campaign'].eql?('Mazda Phase 2')
        @results.push(event['device_id'])
      end
    end
    # @results.concat(body['events'].map{|e| e['event']['json']})

    @results.uniq!
    return if body['next'].nil?
    url_fetch_custom(body['next'])
  end

  def search_query_submit
    response = net_request(search_url)

    return unless response.code == "200"
    body = JSON.parse(response.body)
    body['rsid']["id"]
  end

  def retrive_data
    response = net_request(event_url)

    return unless response.code == "200"
    response.body
  end

  def search_url
    options = {q: "*", from: "2022-02-05 00:00:00.000", until: "now", size: "5000"}.to_query
    SEARCH_URL + options
  end

  def event_url
    options = {q: "*", from: "2022-03-29 00:00:00.000", until: "now", size: "1000"}.to_query
    EVENT_DIRECT_URI + options
  end
end
