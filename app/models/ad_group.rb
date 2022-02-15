# == Schema Information
#
# Table name: ad_groups
#
#  id          :bigint           not null, primary key
#  campaign_id :integer
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class AdGroup < ActiveRecord::Base
end
