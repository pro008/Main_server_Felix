query_type = 'amount'                       # list, amount
maid_type = 'deviceid'                      # deviceid, cookie
find_with_uniq = true                       # true, false (true means MAIDs unique in all. false means unique by creative)
data_type = 'adrequest'                     # adrequest, click
# max_distance is the maximum distance calculate from the v4-location to the client's position
max_distance = 'none' # none / [radius in meter, eg: 100, 200, 300, etc]

object_type = 'campaign' # campaign /. group / creative
object_ids = ['5f43b5116c58d001610fda11'] # campaign id / group id / creative id

device_os = 'all' # android / ios / bb / wp  (bb: blackberry, wp: window phone)

### place date empty ('') when you want to get maids up to date ===
from_date = '2020-08-24'
to_date = '2020-09-14'
platform = 'all' # all, adform, madias, pocket_math, datalift

#============================================== Warning: Do Not change the code below =============================

from_date = from_date.present? ? Date.parse(from_date) : a.start_date
to_date = to_date.present? ? Date.parse(to_date) : a.end_date

creative_ids = if object_type == 'campaign'
                 Creative.where(:campaign_id.in => object_ids)
               elsif object_type == 'group'
                 Creative.where(:ad_group_id.in => object_ids)
               elsif object_type == 'creative'
                 Creative.where(:id.in => object_ids)
               end.pluck(:id).map(&:to_s)

if platform == 'all' && max_distance == 'none'
  query = {
    :creative_id.in => creative_ids,
    :date.gte => from_date,
    :date.lte => to_date
  }
  query.merge!({ device_os: device_os }) if device_os.present? && device_os != 'all'
  query.merge!(is_clicked: true) if data_type == 'click'

  result = Device.where(query)

  if find_with_uniq
    begin
      device_ids = result.distinct(:device_id)
    rescue StandardError
      device_ids = result.pluck(:device_id).uniq
    end
  else
    device_ids = result.pluck(:device_id)
  end
else
  to_date += 1.day
  query = {
    :creativeid.in => creative_ids,
    isvalid: true,
    type: data_type,
    :timestamp.gte => from_date,
    :timestamp.lte => to_date
  }

  query.merge!({ platform: platform }) if platform.present? && platform != 'all'
  query.merge!({ device_os: device_os }) if device_os.present? && device_os != 'all'
  if max_distance.present? && max_distance != 'none'
    query.merge!({ :distance.lte => max_distance.to_f,
                   :distance.gt => 0 })
  end

  result = Event.where(query)

  if find_with_uniq
    begin
      device_ids = result.distinct(:deviceid)
    rescue StandardError
      device_ids = result.pluck(:deviceid).uniq
    end
  else
    device_ids = result.pluck(:deviceid)
  end
end

if maid_type == 'deviceid'
  device_ids = device_ids.inject([]) { |r, t| t[0] != '-' && t.include?('-') ? r << t.downcase : r }
elsif maid_type == 'cookie'
  device_ids = device_ids.inject([]) { |r, t| !t.include?('-') ? r << t.downcase : r }
end

query_type == 'amount' ? [{ amount: device_ids.count }] : device_ids

device_ids = device_ids.inject([]) { |r, t| t[0] != '-' && t.include?('-') ? r << t.downcase : r }
q
CSV.open('device_id.csv', 'w') do |csv|
  device_ids.each do |e|
    csv << [e]
  end
end
