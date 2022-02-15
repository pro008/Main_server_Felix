class Event < ActiveRecord::Base
  belongs_to :platform
  belongs_to :campaign
  belongs_to :creative
  belongs_to :location, foreign_key: :nearest_location_id
end

# == Schema Information
#
# Table name: events
#
#  id                  :bigint           not null, primary key
#  campaign_id         :integer
#  carrier_name        :string
#  conversionid        :string
#  cookieid            :string
#  cookiesites         :string
#  latitude            :float
#  longitude           :float
#  countrycode         :string
#  creative_id         :integer
#  device_id           :string
#  device_model        :string
#  device_os           :string
#  distance            :float
#  dmax                :float
#  host                :string
#  inventorysourcename :string
#  ipheader            :string
#  is_valid            :boolean
#  landed              :boolean
#  visibilitied        :boolean
#  language            :string
#  lineitem            :string
#  nearest_location_id :integer
#  platform_id         :integer
#  remoteaddr          :string
#  type                :string
#  useragent           :string
#  userip              :string
#  zipcode             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
#
