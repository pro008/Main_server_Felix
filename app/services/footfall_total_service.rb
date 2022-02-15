class FootfallService
  def initialize(**opts)
    @footfall_dates  = opts[:footfall_dates]
    @dmax  = opts[:dmax]
    @rest_time  = opts[:rest_time].minutes || 20.minutes
    @max_ff_per_day_by_device  = opts[:max_ff_per_day_by_device] || 3
    @etype = opts[:etype] || 'imp'
    @virtual_locations  = opts[:virtual_locations]
  end

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

  def date_config
    return unless @footfall_dates.present?
    tmp_fds = []
    @footfall_dates.each do |fd|
      if fd.include?('..')
        from_d = DateTime.strptime(fd.split('..')[0], '%Y-%m-%d')
        to_d = DateTime.strptime(fd.split('..')[1], '%Y-%m-%d')
        tmp_fds << (from_d..to_d).to_a
      else
        tmp_fds << DateTime.strptime(fd, '%Y-%m-%d')
      end
    end
    @footfall_dates = tmp_fds.flatten
  end

  def execute(data)
    date_config
    # ca = Campaign.find camp_id
    inf = {}
    foo = {}
    total_foo = {}
    # locations = ca.ad_groups.inject([]) { |r, g| r + g.locations } if virtual_locations.present?
    binding.pry
    data.reverse.each do |event|
      e = event['event']['json']
      datetime = Time.at(event['timestamp']/1000)
      next if e['lat'] == 'unknown' || e['lng'] == 'unknown'

      if e['device_id'] && e['device_id'].include?('-')
        id = e['device_id']
      elsif e['cookieid']
        id = e['cookieid']
      else
        next
      end

      d = e['distance']
      loc = e['nearestlocationname']
      # if virtual_locations.include?(loc)
        # d, nearest_loc = find_nearest_locs(locations, [e['lat'], e['lng]']], virtual_locations)
        d, nearest_loc = find_nearest_without_locs([e['lat'].to_f, e['lng'].to_f])
        loc = nearest_loc
      # end
      next if loc.nil?
      key = "#{id}"
      date = datetime.to_date

      # invalid FF
      # 1. no influence, set first inf 
      # 2. d > dmax 
      # 3. t1 + rest_time > t2
      # 4. t2 + rest_time > t2'
      next if inf[id].nil? && inf[id] = datetime
      next if d > @dmax 
      next if (inf[id] + @rest_time) > datetime
      next if foo[key].present? && foo[key]['date'].last + @rest_time > datetime
      next if @footfall_dates.present? && !@footfall_dates.include?(date)
      # valid FF
      # not exist FF before
      if foo[key].nil?
        foo[key] = {
          'location_name' => loc,
          'deviceid' => id,
          'date' => [datetime],
          date => 1,
          'count' => 1
        }
        total_foo[loc] ||= 0
        total_foo[loc] += 1
      else
        # FF appear in next day => valid
        if foo[key]['date'].last.to_date < date
          foo[key]['date'] << datetime
          foo[key]['count'] += 1
          foo[key][date] = 1
          total_foo[loc] ||= 0
          total_foo[loc] += 1
        # FF in the same day
        # 1. check max_ff_per_day_by_device
        # 2. check rest_time. t2 > t1'
        elsif foo[key]['date'].last.to_date == date && foo[key][date] < @max_ff_per_day_by_device && 
          foo[key]['date'] << datetime
          foo[key]['count'] += 1
          foo[key][date] += 1
          total_foo[loc] += 1
        end
      end
    end

    t=[]
    r = []
    total_foo.each do |k,v|
      r << {name: k, footfall: v}
    end

    r
  end
end