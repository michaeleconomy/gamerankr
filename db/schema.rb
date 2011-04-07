# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110406154431) do

  create_table "admins", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["user_id"], :name => "index_admins_on_user_id", :unique => true

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",       :null => false
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.text     "body",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designer_games", :force => true do |t|
    t.integer  "designer_id", :null => false
    t.integer  "game_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "designers", :force => true do |t|
    t.string   "name"
    t.integer  "designer_games_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "developer_games", :force => true do |t|
    t.integer  "developer_id", :null => false
    t.integer  "game_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "port_id",      :null => false
  end

  create_table "developers", :force => true do |t|
    t.string   "name"
    t.integer  "developer_games_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_genres", :force => true do |t|
    t.integer  "game_id",    :null => false
    t.integer  "genre_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.string   "title"
    t.integer  "series_id"
    t.text     "description"
    t.integer  "rankings_count",                 :default => 0, :null => false
    t.string   "rating"
    t.string   "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "initially_released_at_accuracy"
    t.datetime "initially_released_at"
  end

  create_table "genres", :force => true do |t|
    t.integer  "game_genres_count",                :default => 0, :null => false
    t.string   "name",              :limit => 100,                :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "genres", ["game_genres_count"], :name => "index_genres_on_game_genres_count"
  add_index "genres", ["name"], :name => "index_genres_on_name", :unique => true

  create_table "platforms", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ports", :force => true do |t|
    t.integer  "game_id",              :null => false
    t.integer  "platform_id"
    t.datetime "released_at"
    t.string   "source"
    t.string   "asin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upc"
    t.string   "ean"
    t.string   "manufacturer"
    t.string   "title"
    t.string   "released_at_accuracy"
    t.string   "brand"
    t.integer  "amazon_price"
    t.string   "amazon_url"
    t.datetime "amazon_updated_at"
    t.string   "amazon_image_url"
    t.string   "binding"
    t.text     "amazon_description"
  end

  create_table "publisher_games", :force => true do |t|
    t.integer  "publisher_id", :null => false
    t.integer  "game_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "port_id",      :null => false
  end

  create_table "publishers", :force => true do |t|
    t.string   "name"
    t.integer  "publisher_games_count", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ranking_shelves", :force => true do |t|
    t.integer  "ranking_id", :null => false
    t.integer  "shelf_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rankings", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "ranking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "game_id",     :null => false
    t.integer  "port_id",     :null => false
    t.text     "review"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

  create_table "secrets", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shelves", :force => true do |t|
    t.integer  "user_id",                                            :null => false
    t.integer  "ranking_shelves_count",               :default => 0, :null => false
    t.string   "name",                  :limit => 48,                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "handle",         :limit => 20
    t.string   "real_name"
    t.text     "about"
    t.integer  "comments_count",               :default => 0, :null => false
    t.integer  "rankings_count",               :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
