# == Schema Information
#
# Table name: locations
#
#  id          :bigint           not null, primary key
#  ad_group_id :integer
#  name        :string
#  latitude    :float
#  longitude   :float
#  radius      :float
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Location < ActiveRecord::Base
end