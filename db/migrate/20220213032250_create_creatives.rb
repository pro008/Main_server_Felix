class CreateCreatives < ActiveRecord::Migration[7.0]
  def change
    create_table :creatives do |t|
      t.string :name
      t.integer :creative_type
      t.integer :ad_group_id
      t.integer :platform_id
      t.string :landing_url
      t.integer :landing_type
      t.string :client_imp_url1
      t.string :client_imp_url2
      t.string :client_imp_url3
      t.string :client_clk_url1
      t.string :client_clk_url2
      t.string :client_clk_url3
      t.timestamps
    end
  end
end
