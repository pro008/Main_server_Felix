# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_02_13_032250) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ad_groups", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "creatives", force: :cascade do |t|
    t.string "name"
    t.integer "creative_type"
    t.integer "ad_group_id"
    t.integer "platform_id"
    t.string "landing_url"
    t.integer "landing_type"
    t.string "client_imp_url1"
    t.string "client_imp_url2"
    t.string "client_imp_url3"
    t.string "client_clk_url1"
    t.string "client_clk_url2"
    t.string "client_clk_url3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer "campaign_id"
    t.string "carrier_name"
    t.string "conversionid"
    t.string "cookieid"
    t.string "cookiesites"
    t.float "latitude"
    t.float "longitude"
    t.string "countrycode"
    t.integer "creative_id"
    t.string "device_id"
    t.string "device_model"
    t.string "device_os"
    t.float "distance"
    t.float "dmax"
    t.string "host"
    t.string "inventorysourcename"
    t.string "ipheader"
    t.boolean "is_valid"
    t.boolean "landed"
    t.boolean "visibilitied"
    t.string "language"
    t.string "lineitem"
    t.integer "nearest_location_id"
    t.integer "platform_id"
    t.string "remoteaddr"
    t.string "type"
    t.string "useragent"
    t.string "userip"
    t.string "zipcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer "ad_group_id"
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.float "radius"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "platforms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
