require 'csv'

class ExportEventService
  HEADERS = {
    id: 'id',
    carrier_name: 'carrier_name',
    conversion_id: 'conversionid',
    cookieid: 'cookieid',
    cookiesites: 'cookiesites',
    site: 'site',
    lat: 'latitude',
    lng: 'longitude',
    country_code: 'countrycode',
    creative_id: 'creative_id',
    device_id: 'device_id',
    model_name: 'device_model',
    device_os: 'device_os',
    app_name: 'app_name',
    exchange: 'ad_exchange',
    host: 'host',
    inventorysourcename: 'inventorysourcename',
    ipheader: 'ipheader',
    language: 'language',
    userip: 'userip',
    zipcode: 'zipcode',
    model_category: 'model_category',
    app_or_web: 'environment',
    gdpr: 'gdpr',
    type: 'ad_type',
    pub_id: 'pub_id',
    pub_keyword: 'pub_keyword',
    pub_store: 'pub_store',
    timestamp: 'received_at',
    user_ip: 'userip'
  }

  def initialize(campaign_name, delay_hour = 0)
    @campaign_name = campaign_name
    @campaign = Campaign.find_by(name: campaign_name)
    @delay_hour = delay_hour
  end

  def export_all
    CSV.open("#{@campaign_name}_raw_data.csv", 'w') do |csv|
      csv << headers
      Event.where(campaign_id: @campaign.id).order(received_at: :desc).find_in_batches(batch_size: 100_000).with_index do |group_e, batch|
        puts(batch)
        group_e.each do |e|
          data = [@campaign_name] + HEADERS.map { |_k, v| e[v] } + [config_date(e.received_at)]
          csv << data
        end
        sleep(2)
      end
    end
  end

  def export_by_date(start_time, end_time)
    start_date = Date.parse(start_time)
    end_date = Date.parse(end_time)
    (start_date..end_date).each do |date|
      next if @results.empty?

      CSV.open("#{@campaign_name}_raw_data_#{date.strftime('%B_%d_%Y')}.csv", 'w') do |csv|
        csv << headers
        Event.where(campaign_id: @campaign.id).where('received_at > (?) AND received_at < (?)',
                                                              date.beginning_of_day,
                                                              date.end_of_day).each do |e|
          data = [@campaign_name] + HEADERS.map { |_k, v| e[v] } + [format_date(e['received_at'])]
          csv << data
        end
      end
    end
  end

  def headers
    ['campaign'] + HEADERS.values + ['timestamp']
  end

  def format_date(date)
    current_time = Time.parse(date) - @delay_hour.hours
    current_time.to_s
  end

  def config_date(date)
    date - @delay_hour.hours
  end
end
