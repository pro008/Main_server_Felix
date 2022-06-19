class CreateCampaigns < ActiveRecord::Migration[7.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.datetime :last_updated_at
      t.timestamps
    end
  end
end
