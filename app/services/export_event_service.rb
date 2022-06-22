require 'csv'

class ExportEventService
  HEADERS = {
    carrier_name: 'carrier_name',
    type: 'ad_type',
    creative_id: 'creative_id',
    lat: 'latitude',
    lng: 'longitude',
    device_os: 'device_os',
    device_id: 'device_id',
    model_name: 'device_model',
    app_name: 'app_name',
    exchange: 'ad_exchange',
    user_ip: 'userip',
    country_code: 'countrycode',
    conversion_id: 'conversionid',
    model_category: 'model_category',
    site: 'site',
    app_or_web: 'environment',
    gdpr: 'gdpr',
    pub_id: 'pub_id',
    pub_keyword: 'pub_keyword',
    pub_store: 'pub_store'
  }

  def initialize(campaign_name, delay_hour = 0)
    @campaign_name = campaign_name
    @campaign = Campaign.find_by(name: campaign_name)
    @delay_hour = delay_hour
  end

  def export_all
    @results = Event.where(campaign_id: @campaign.id).as_json

    CSV.open("#{@campaign_name}_raw_data.csv", 'w') do |csv|
      csv << headers
      @results.each do |e|
        data = [@campaign_name] + HEADERS.map { |_k, v| e[v] } + [format_date(e['received_at'])]
        csv << data
      end
    end
  end

  def export_by_date(start_time, end_time)
    start_date = Date.parse(start_time)
    end_date = Date.parse(end_time)
    (start_date..end_date).each do |date|
      @results = Event.where(campaign_id: @campaign.id).where('received_at > (?) AND received_at < (?)',
                                                              date.beginning_of_day,
                                                              date.end_of_day).as_json
      next if @results.empty?

      CSV.open("#{@campaign_name}_raw_data_#{date.strftime('%B_%d_%Y')}.csv", 'w') do |csv|
        csv << headers
        @results.each do |e|
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
end
