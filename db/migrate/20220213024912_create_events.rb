class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :campaign_id
      t.string :carrier_name
      t.string :conversionid
      t.string :cookieid
      t.string :cookiesites
      t.string :site
      t.float :latitude
      t.float :longitude
      t.string :countrycode
      t.string :creative_id
      t.string :device_id
      t.string :device_model
      t.string :device_os
      t.string :app_name
      t.string :ad_exchange
      t.float :distance
      t.float :dmax
      t.string :host
      t.string :inventorysourcename
      t.string :ipheader
      t.boolean :is_valid
      t.boolean :landed
      t.boolean :visibilitied
      t.string :language
      t.string :lineitem
      t.integer :nearest_location_id
      t.integer :platform_id
      t.string :remoteaddr
      t.string :ad_type
      t.string :useragent
      t.string :userip
      t.string :zipcode
      t.string :model_category
      t.string :environment
      t.string :gdpr
      t.string :pub_id
      t.string :pub_keyword
      t.string :pub_store
      t.string :placement_id
      t.string :referer
      t.string :gdpr_consent
      t.string :msxt
      t.datetime :received_at
      t.timestamps null: false
    end
  end
end
