# == Schema Information
#
# Table name: campaigns
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Campaign < ActiveRecord::Base
end
