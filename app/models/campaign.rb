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
  def last_event_at_of_event
    Event.where(campaign_id: Campaign.last.id).order(received_at: :desc).first.received_at
  end

  def update_update_latest_at
    update(last_updated_at: last_event_at_of_event)
  end
end
