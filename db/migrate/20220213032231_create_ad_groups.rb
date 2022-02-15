class CreateAdGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :ad_groups do |t|
      t.integer :campaign_id
      t.string :name
      t.timestamps
    end
  end
end
