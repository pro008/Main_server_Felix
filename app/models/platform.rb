# == Schema Information
#
# Table name: platforms
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Platform < ActiveRecord::Base
end
