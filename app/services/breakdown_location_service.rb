class BreakdownLocationService
  def initialize(**opts)
    @etype = opts[:etype] || 'imp'
    @virtual_locations = opts[:virtual_locations] # {destination: {lat: 44.478395, lng:26.103578}}
  end

  # BreakdownLocationService.new(virtual_locations: virtual_locations, etype: 'imp').execute(@results)

  def distance(loc1, loc2)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlat_rad = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad, = loc1.map { |i| i * rad_per_deg }
    lat2_rad, = loc2.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

    rm * c # Delta in meters
  end

  def find_nearest_locs(locations, client_loc)
    nearest_loc = nil
    distance = -1
    locations.each do |loc|
      next if @virtual_locations.include?(loc.name)
      d = distance([loc.latitude, loc.longitude], client_loc)
      if distance < 0 || distance > d
        distance = d
        nearest_loc = loc
      end
    end

    [distance, nearest_loc]
  end

  def find_nearest_without_locs(client_loc)
    nearest_loc = nil
    distance = -1
    if @virtual_locations.is_a?(Array)
      @virtual_locations.each do |loc|
        d = distance([loc.latitude, loc.longitude], client_loc)
        if distance < 0 || distance > d
          distance = d
          nearest_loc = loc
        end
      end
      return [distance, nearest_loc]
    else
      @virtual_locations.each do |loc_name, coord|
        d = distance([coord[:lat], coord[:lng]], client_loc)
        if distance < 0 || distance > d
          distance = d
          nearest_loc = loc_name
        end
      end
      return [distance, nearest_loc]
    end
  end

  def execute(data, numbers)
    results = {}

    @virtual_locations.keys.each{|loc| results["#{loc}"] ||= 0 }
    # locations = ca.ad_groups.inject([]) { |r, g| r + g.locations } if virtual_locations.present?
    data.reverse.each_with_index do |e, i|
      next if e['campaign'] != 'CP'
      next unless e['type'].eql? @etype
      # e = event['event']['json']
      # datetime = Time.at(event['timestamp']/1000)
      d = e['distance']
      loc = e['nearestlocationname']
      # if virtual_locations.include?(loc)
        # d, nearest_loc = find_nearest_locs(locations, [e['lat'], e['lng]']], virtual_locations)
      d, nearest_loc = find_nearest_without_locs([e['lat'].to_f, e['lng'].to_f])
      loc = nearest_loc.to_s

      results["#{nearest_loc}"] += 1
    end

    results = adjustable_numbers(results, numbers)
    results
  end

  def adjustable_numbers(data, numbers)
    new_hash = {}
    total_views = data.values.sum
    remain_number = numbers - total_views
    ratio = remain_number.to_f / total_views

    highest = 0
    key = 0
    data.each do |k,v|
      adjustable_number = v + (v * ratio)
      new_hash[k] ||= 0
      new_hash[k] = adjustable_number.ceil
      key,highest = [k, new_hash[k]] if highest < new_hash[k]
    end

    new_hash[key] = new_hash[key] + (numbers - new_hash.values.sum)
    new_hash
  end
end