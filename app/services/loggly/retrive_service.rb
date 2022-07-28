class Loggly::RetriveService
  SEARCH_URL = 'https://aboutmedia.loggly.com/apiv2/search?'
  EVENT_URL = 'https://aboutmedia.loggly.com/apiv2/events?rsid='
  EVENT_DIRECT_URI = 'https://aboutmedia.loggly.com/apiv2/events/iterate?'
  API_TOKEN = '5f4cec61-b124-4da8-bfea-637da2e54c83'

  # superbet 17/02
  def initialize(campaign_name = '', creative = '', store = false)
    @campaign_name = campaign_name
    @creative = creative
    @results = []
    @store = store
    @done = false
    post_init
  end

  attr_reader :campaign_name, :creative, :results, :campaign, :store

  def post_init
    return unless @store

    @campaign = Campaign.find_or_create_by(name: campaign_name)
  end

  def pre_init
    return unless @store

    @campaign = Campaign.update(last_updated_at: @first_record)
  end

  def net_request(url)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "bearer #{API_TOKEN}"

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  def fetch_data
    url_fetch
    pre_init
    @results
  end

  def fetch_maids
    url_fetch_custom
    @results
  end

  def url_fetch(next_page_url = nil)
    final_url = next_page_url || event_url_v2
    response = net_request(final_url)
    return unless response.code == '200'

    body = JSON.parse(response.body)

    last_time = body['events'].last['timestamp']
    p Time.at(last_time / 1000)

    @first_record = Time.at(body['events'].first['timestamp'] / 1000) if next_page_url.nil?
    if store
      parse_body_and_store(body['events'])
    else
      parse_body_as_json(body['events'])
    end

    return if body['next'].nil? || @done == true

    url_fetch(body['next'])

    nil
  end

  def url_fetch_custom(next_page_url = nil)
    final_url = next_page_url || event_url_v2
    response = net_request(final_url)
    campaign.update(last_updated_at: last_record)

    return unless response.code == '200'

    body = JSON.parse(response.body)

    last_time = body['events'].last['timestamp']
    p Time.at(last_time / 1000)

    body['events'].each do |e|
      event = e['event']['json']
      @results.push(event['device_id']) if event['campaign'].eql?(campaign_name)
    end
    # @results.concat(body['events'].map{|e| e['event']['json']})

    @results.uniq!
    return if body['next'].nil?

    url_fetch_custom(body['next'])
    nil
  end

  def search_query_submit
    response = net_request(search_url)

    return unless response.code == '200'

    body = JSON.parse(response.body)
    body['rsid']['id']
  end

  def retrive_data
    response = net_request(event_url)

    return unless response.code == '200'

    response.body
  end

  def parse_body_as_json(body)
    body.each do |e|
      event = e['event']['json']
      timestamp = Time.at(e['timestamp'] / 1000)
      event['timestamp'] = timestamp
      @results.push(event)
    end
    # @results.concat(body['events'].map{|e| e['event']['json']})
  end

  def parse_body_and_store(body)
    first_record = Time.at(body.first['timestamp'] / 1000)
    is_last_updated_nil = campaign.last_updated_at.nil?
    return(@done = true) if !is_last_updated_nil && campaign.last_updated_at >= first_record

    body.each do |e|
      begin
        event = e['event']['json']
        timestamp = Time.at(e['timestamp'] / 1000)
        event['timestamp'] = timestamp
        next if !is_last_updated_nil && campaign.last_updated_at > timestamp

        ImportEventService.create(event, campaign.id)
      rescue
      end
    end
  end

  def search_url
    options = { q: '*', from: '2022-02-05 00:00:00.000', until: 'now', size: '5000' }.to_query
    SEARCH_URL + options
  end

  def event_url
    options = { q: '*', from: '2022-03-29 00:00:00.000', until: 'now', size: '1000' }.to_query
    EVENT_DIRECT_URI + options
  end

  def event_url_v2
    # from_date = campaign.last_updated_at if store
    from_date ||= '2022-07-15 06:30:26'
    options = { q: campaign_name, from: from_date, until: 'now', size: '1000' }.to_query
    EVENT_DIRECT_URI + options
  end

  def custom_event_url_v2
    from_date = campaign.last_updated_at if store
    from_date ||= '2022-05-01 00:00:00.000'
    options = { q: campaign_name, from: from_date, until: 'now', size: '1000' }.to_query
    EVENT_DIRECT_URI + options
  end
end
