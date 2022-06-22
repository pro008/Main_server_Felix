require 'csv'
# headers =  ['app_or_web', 'placement_id', 'model_category', 'lat', 'lng', 'timestamp','device_id', 'device_os','app_name']

c = Campaign.find_by(name: 'Donau Niederösterreich Tourismus GmbH - DONAUGÄRTEN 2022')
@results = Event.where(campaign_id: c.id).as_json

# for device id only
device_ids = @results.map { |e| e['device_id'] }.uniq
q
device_ids = device_ids.inject([]) { |r, t| t[0] != '-' && t.include?('-') ? r << t.downcase : r }
q
CSV.open('device_id.csv', 'w') do |csv|
  device_ids.each do |e|
    csv << [e]
  end
end

headers = @results.first.keys
CSV.open('raw_data.csv', 'w') do |csv|
  csv << headers
  @results.each do |e|
    csv << headers.map { |v| e[v] }
  end
end

# footfall
require 'csv'
CSV.open('footfall.csv', 'w') do |csv|
  csv << r.first.keys
  r.each do |e|
    csv << e.values
  end
end

# maids lat lng
headers = %w[device_id
             lat lng]
CSV.open('raw_data.csv', 'w') do |csv|
  csv << headers
  @results.each do |e|
    csv << headers.map { |v| e[v] }
  end
end

# new version export raw_data
campaign_name = 'A'
headers = {
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
  timestamp: 'received_at',
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

CSV.open('raw_data.csv', 'w') do |csv|
  csv << (['campaign'] + headers.values)
  @results.each do |e|
    data = [campaign_name] + headers.map { |_k, v| e[v] }
    csv << data
  end
end
