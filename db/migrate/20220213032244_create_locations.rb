class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.integer :ad_group_id
      t.string :name
      t.float :latitude
      t.float :longitude
      t.float :radius
      t.string :description
      t.timestamps
    end
  end
end
