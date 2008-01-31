# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 14) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "activity",  :null => false
  end

  create_table "batteries", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :limit => 1, :null => false
    t.integer  "time_remaining",              :null => false
  end

  create_table "call_orders", :force => true do |t|
    t.integer "user_id"
    t.integer "caregiver_id"
    t.integer "position"
    t.integer "active",       :limit => 1, :null => false
    t.integer "phone_active", :limit => 1, :null => false
    t.integer "email_active", :limit => 1, :null => false
    t.integer "text_active",  :limit => 1, :null => false
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.string   "kind"
    t.integer  "kind_id"
    t.datetime "timestamp"
  end

  create_table "falls", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "magnitude", :limit => 2, :null => false
  end

  create_table "heartrates", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "heartrate", :limit => 1, :null => false
  end

  create_table "orientations", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.boolean  "orientation"
  end

  create_table "panics", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
  end

  create_table "profiles", :force => true do |t|
    t.integer "user_id"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "address"
    t.string  "city"
    t.string  "state"
    t.string  "home_phone"
    t.string  "work_phone"
    t.string  "cell_phone"
    t.string  "relationship"
    t.string  "email",        :default => "", :null => false
  end

  create_table "raw_data_files", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "parent_id"
    t.datetime "created_at"
  end

  create_table "skin_temps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "skin_temp", :limit => 2, :null => false
  end

  create_table "steps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_timestamp"
    t.datetime "end_timestamp"
    t.integer  "steps",           :limit => 1, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "image"
    t.string   "type"
  end

  create_table "vitals", :force => true do |t|
  end

end
