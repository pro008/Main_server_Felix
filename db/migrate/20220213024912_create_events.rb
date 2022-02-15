class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.integer :campaign_id
      t.string :carrier_name
      t.string :conversionid
      t.string :cookieid
      t.string :cookiesites
      t.float :latitude
      t.float :longitude
      t.string :countrycode
      t.integer :creative_id
      t.string :device_id
      t.string :device_model
      t.string :device_os
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
      t.string :type
      t.string :useragent
      t.string :userip
      t.string :zipcode

      t.timestamps null: false
    end
  end
end
