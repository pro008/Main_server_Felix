require 'csv'
# headers =  ['app_or_web', 'placement_id', 'model_category', 'lat', 'lng', 'timestamp','device_id', 'device_os','app_name']
 


# for device id only
device_ids = @results.map{|e| e['device_id']}.uniq
q
device_ids = device_ids.inject([]) { |r, t| t[0] != '-' && t.include?('-') ? r << t.downcase : r }
q
CSV.open("device_id.csv", "w") do |csv|
  device_ids.each do |e|
    csv << [e]
  end
end

headers = @results.first.keys
CSV.open("raw_data.csv", "w") do |csv|
  csv << headers
  @results.each do |e|
    csv << headers.map{|v| e[v]}
  end
end


# footfall
require 'csv'
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
