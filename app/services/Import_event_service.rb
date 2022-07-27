class ImportEventService
  def initialize; end

  def self.create(event, campaign_id)
    event = ActiveSupport::HashWithIndifferentAccess.new(event)
    Event.create(
      campaign_id: campaign_id,
      carrier_name: event[:carrier_name],
      ad_type: event[:type],
      creative_id: event[:creative_id],
      latitude: event[:lat],
      longitude: event[:lng],
      device_os: event[:device_os],
      device_id: event[:device_id],
      device_model: event[:model_name],
      app_name: event[:app_name],
      ad_exchange: event[:exchange],
      received_at: event[:timestamp],
      userip: event[:user_ip],
      countrycode: event[:country_code],
      conversionid: event[:conversion_id],
      model_category: event[:model_category],
      site: event[:site],
      environment: event[:app_or_web],
      gdpr: event[:gdpr],
      pub_id: event[:pub_id],
      pub_keyword: event[:pub_keyword],
      pub_store: event[:pub_store],
      placement_id: event[:placement_id],
      referer: event[:referer],
      gdpr_consent: event[:gdpr_consent],
      msxt: event[:msxt]
    )
  end
end

# campaigns = ['A', 'B']
# campaigns.each{|c| Loggly::RetriveService.new(c, '', true).fetch_data}