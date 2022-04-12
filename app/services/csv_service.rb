require 'csv'
# headers =  ['app_or_web', 'placement_id', 'model_category', 'lat', 'lng', 'timestamp','device_id', 'device_os','app_name']
headers = ["referer",
  "app_or_web",
  "cache_buster",
  "gdpr_consent",
  "type",
  "creative_id",
  "placement_id",
  "msxt",
  "model_name",
  "model_category",
  "carrier_name",
  "lat",
  "timestamp",
  "pub_id",
  "user_ip",
  "conversion_id",
  "lng",
  "device_id",
  "device_os",
  "gdpr",
  "app_name",
  "country_code",
  "pub_keyword",
  "site",
  "campaign",
  "exchange"]
CSV.open("raw_data.csv", "w") do |csv|
  csv << headers
  @results.each do |e|
    csv << headers.map{|v| e[v]}
  end
end



# for device id only
device_ids = @results.map{|e| e['device_id']}
q
device_ids = device_ids.inject([]) { |r, t| t[0] != '-' && t.include?('-') ? r << t.downcase : r }
q
CSV.open("device_id.csv", "w") do |csv|
  device_ids.each do |e|
    csv << [e]
  end
end



# footfall
CSV.open("footfall.csv", "w") do |csv|
  csv << r.first.keys
  r.each do |e|
    csv << e.values
  end
end





# maids lat lng
headers = ["device_id",
  "lat", 'lng']
CSV.open("raw_data.csv", "w") do |csv|
  csv << headers
  @results.each do |e|
    csv << headers.map{|v| e[v]}
  end
end
