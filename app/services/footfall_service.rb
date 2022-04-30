class FootfallService
  def initialize(**opts)
    @footfall_dates = opts[:footfall_dates]
    @dmax = opts[:dmax] || 100
    @rest_time = opts[:rest_time]&.minutes || 20.minutes
    @max_ff_per_day_by_device  = opts[:max_ff_per_day_by_device] || 3
    @etype = opts[:etype] || 'imp'
    @virtual_locations = opts[:virtual_locations] # {destination: {lat: 44.478395, lng:26.103578}}
  end

  # FootfallService.new(virtual_locations: virtual_locations, footfall_dates: ['2022-03-01..2022-05-20'], dmax: 500).execute(s)

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
    data.reverse.each_with_index do |event, i|
      # e = event['event']['json']
      # datetime = Time.at(event['timestamp']/1000)
      e = event
      datetime = e['timestamp']
      next if e['lat'] == 'unknown' || e['lng'] == 'unknown'

      if e['device_id'] && e['device_id'].include?('-')
        maid = e['device_id']
      elsif e['cookieid']
        maid = e['cookieid']
      else
        next
      end

      d = e['distance']
      loc = e['nearestlocationname']
      # if virtual_locations.include?(loc)
        # d, nearest_loc = find_nearest_locs(locations, [e['lat'], e['lng]']], virtual_locations)
        d, nearest_loc = find_nearest_without_locs([e['lat'].to_f, e['lng'].to_f])
        loc = nearest_loc.to_s
      # end
      next if loc.nil?

      date = datetime.to_date
      date_str = date.strftime('%Y-%m-%d')
      inf_key = maid
      foo_key = "#{maid}-#{loc}"

      # invalid FF
      # 1. no influence, set first inf 
      # 2. d > dmax 
      # 3. t1 + rest_time > t2
      # 4. t2 + rest_time > t2'
      next if inf[inf_key].nil? && inf[inf_key] = {datetime: datetime, loc: loc}
      next if d < 0 || d > @dmax 
      next if (inf[inf_key][:datetime] + @rest_time) > datetime
      next if @footfall_dates.present? && !@footfall_dates.include?(date)
      next if foo[foo_key].present? && foo[foo_key]['last_datetime'] + @rest_time > datetime
      next if foo[foo_key].present? && foo[foo_key][date].present? && foo[foo_key][date] >= @max_ff_per_day_by_device

      total_key = loc.parameterize + '-' + date_str + '-' + inf[inf_key][:loc]
      # valid FF
      foo[foo_key] ||= {
        'location_name' => loc,
        'deviceid' => maid,
        'last_datetime' => datetime
      }
      foo[foo_key][date] ||= 0
      foo[foo_key][date] += 1

      total_foo[total_key] ||= {'Location Name' => loc, 'Date' => date, 'Footfall' => 0, 'Influence Location Name' => inf[inf_key][:loc]}
      total_foo[total_key]['Footfall'] += 1
    end

    # r = []
    db_report = {}

    total_foo.each do |_, v|
      date = v['Date'].strftime('%Y-%m-%d')
      ff_name = v['Location Name']
      inf_name = v['Influence Location Name']
      amount_ff = v['Footfall']
      db_report[date] ||= {
        'Date' => date,
        'No. of footfalls' => 0,
        'Influence Location Name' => '',
        'key' => date,
        'parent' => '',
        'detail' => {}
      }

      db_report[date]['No. of footfalls'] += amount_ff
      db_detail_key = "#{ff_name}-#{inf_name}"
      db_report[date]['detail'][db_detail_key] ||= {
        'Date' => ff_name,
        'No. of footfalls' => amount_ff,
        'Influence Location Name' => inf_name,
        'key' => '',
        'parent' => date,
      }

      # r << {'Location Name' => v['Location Name'], 'Date' => v['Date'].strftime('%Y-%m-%d').to_s, 'Footfall' => v['Footfall'], 'Influence Location Name' => v['Influence Location Name']}
    end

    r = []
    db_report.values.each do |report|
      r << report.except('detail')
      r += report['detail'].values
    end

    r
  end
end