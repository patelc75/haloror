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

ActiveRecord::Schema.define(:version => 37) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "activity",  :null => false
  end

  create_table "batteries", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
  end

  create_table "device_infos", :force => true do |t|
    t.integer "device_id"
    t.string  "serial_number"
    t.string  "mac_address"
    t.string  "vendor"
    t.string  "model"
    t.string  "kind"
    t.integer "kind_id"
  end

  create_table "devices", :force => true do |t|
    t.integer "user_id"
    t.string  "serial_number"
  end

  create_table "dial_ups", :force => true do |t|
    t.integer "phone_number"
  end

  create_table "dial_ups_gateways", :id => false, :force => true do |t|
    t.integer "gateway_id"
    t.integer "dial_up_id"
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
    t.integer  "magnitude", :null => false
  end

  create_table "firmware_upgrades", :force => true do |t|
    t.integer "ftp_id"
    t.string  "version"
  end

  create_table "ftps", :force => true do |t|
    t.string "server_name"
    t.string "login"
    t.string "password"
    t.string "path"
  end

  create_table "gateways", :force => true do |t|
    t.string  "serial_number"
    t.string  "mac_address"
    t.string  "vendor"
    t.string  "model"
    t.string  "kind"
    t.integer "kind_id"
  end

  create_table "heartrates", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "heartrate", :null => false
  end

  create_table "mgmt_acks", :force => true do |t|
    t.integer  "mgmt_cmd_id"
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
  end

  create_table "mgmt_cmds", :force => true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.string   "cmd_type"
    t.datetime "timestamp_initiated"
    t.datetime "timestamp_sent"
    t.string   "originator"
    t.string   "status"
    t.boolean  "pending",             :default => true
  end

  create_table "mgmt_queries", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
    t.integer  "poll_rate"
  end

  create_table "mgmt_responses", :force => true do |t|
    t.integer  "mgmt_cmd_id"
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
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
    t.string  "email"
    t.string  "text_email"
  end

  create_table "raw_data_files", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "parent_id"
    t.datetime "created_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 30
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users_options", :force => true do |t|
    t.integer "role_id"
    t.boolean "removed",      :default => false
    t.boolean "active",       :default => false
    t.boolean "phone_active", :default => false
    t.boolean "email_active", :default => false
    t.boolean "text_active",  :default => false
    t.integer "position",     :default => 0
    t.integer "user_id"
  end

  create_table "skin_temps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "skin_temp", :null => false
  end

  create_table "steps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_timestamp"
    t.datetime "end_timestamp"
    t.integer  "steps",           :null => false
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
    t.integer "heartrate"
    t.integer "hrv"
    t.integer "activity"
    t.integer "orientation"
  end

end
