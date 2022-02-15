# == Schema Information
#
# Table name: creatives
#
#  id              :bigint           not null, primary key
#  name            :string
#  creative_type   :integer
#  ad_group_id     :integer
#  platform_id     :integer
#  landing_url     :string
#  landing_type    :integer
#  client_imp_url1 :string
#  client_imp_url2 :string
#  client_imp_url3 :string
#  client_clk_url1 :string
#  client_clk_url2 :string
#  client_clk_url3 :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Creative < ActiveRecord::Base
end
