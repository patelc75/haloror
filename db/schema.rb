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

ActiveRecord::Schema.define(:version => 129) do

  create_table "access_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_logs", ["user_id"], :name => "index_access_logs_on_user_id"

  create_table "alert_groups", :force => true do |t|
    t.string   "group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alert_groups_alert_types", :id => false, :force => true do |t|
    t.integer "alert_group_id"
    t.integer "alert_type_id"
  end

  create_table "alert_options", :force => true do |t|
    t.integer  "roles_user_id"
    t.integer  "alert_type_id"
    t.boolean  "phone_active"
    t.boolean  "email_active"
    t.boolean  "text_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alert_types", :force => true do |t|
    t.integer  "alert_group_id"
    t.string   "alert_type"
    t.boolean  "phone_active"
    t.boolean  "email_active"
    t.boolean  "text_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batteries", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "device_id"
  end

  add_index "batteries", ["user_id", "timestamp"], :name => "index_batteries_on_timestamp_and_user_id"

  create_table "battery_charge_completes", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "user_id"
  end

  add_index "battery_charge_completes", ["device_id"], :name => "index_battery_charge_completes_on_device_id"

  create_table "battery_criticals", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "user_id"
  end

  add_index "battery_criticals", ["device_id"], :name => "index_battery_criticals_on_device_id"

  create_table "battery_pluggeds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "user_id"
  end

  create_table "battery_unpluggeds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "user_id"
  end

  create_table "call_center_steps", :force => true do |t|
    t.string   "type"
    t.text     "text"
    t.text     "answer"
    t.integer  "next_step_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carriers", :force => true do |t|
    t.string "name"
    t.string "domain"
  end

  create_table "device_alerts", :force => true do |t|
  end

  create_table "device_available_alerts", :force => true do |t|
    t.integer  "device_id",  :null => false
    t.datetime "created_at", :null => false
    t.integer  "priority"
  end

  add_index "device_available_alerts", ["device_id"], :name => "device_available_alerts_device_id_idx"

  create_table "device_infos", :force => true do |t|
    t.integer "device_id"
    t.string  "serial_number"
    t.string  "mac_address"
    t.string  "vendor"
    t.string  "model"
    t.string  "device_info_type"
    t.integer "device_info_id"
    t.integer "user_id"
    t.string  "hardware_version"
    t.string  "software_version"
    t.integer "mgmt_response_id"
  end

  create_table "device_latest_queries", :force => true do |t|
    t.datetime "updated_at", :null => false
  end

  add_index "device_latest_queries", ["updated_at"], :name => "device_latest_queries_updated_at_idx"

  create_table "device_strap_status", :force => true do |t|
    t.integer  "is_fastened", :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "device_unavailable_alerts", :force => true do |t|
    t.integer  "device_id",                      :null => false
    t.integer  "number_attempts", :default => 1, :null => false
    t.datetime "reconnected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority"
  end

  add_index "device_unavailable_alerts", ["device_id"], :name => "device_unavailable_alerts_device_id_idx"
  add_index "device_unavailable_alerts", ["device_id"], :name => "device_unavailable_alerts_device_unavailable_idx"

  create_table "devices", :force => true do |t|
    t.string "serial_number"
    t.string "device_type"
  end

  create_table "devices_user", :force => true do |t|
    t.integer "device_id"
    t.integer "user_id"
  end

  create_table "devices_users", :id => false, :force => true do |t|
    t.integer "device_id"
    t.integer "user_id"
  end

  add_index "devices_users", ["device_id"], :name => "index_devices_users_on_device_id"
  add_index "devices_users", ["user_id"], :name => "index_devices_users_on_user_id"

  create_table "dial_ups", :force => true do |t|
    t.integer "phone_number"
  end

  create_table "dial_ups_gateways", :id => false, :force => true do |t|
    t.integer "gateway_id"
    t.integer "dial_up_id"
  end

  create_table "emails", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.integer  "last_send_attempt", :default => 0
    t.text     "mail"
    t.datetime "created_on"
    t.integer  "priority"
  end

  create_table "event_actions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.string   "event_type"
    t.integer  "event_id"
  end

  create_table "falls", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "magnitude", :null => false
  end

  create_table "firmware_upgrades", :force => true do |t|
    t.integer "ftp_id"
    t.string  "version"
    t.string  "filename"
    t.text    "description"
    t.date    "date_added"
  end

  create_table "ftps", :force => true do |t|
    t.string "server_name"
    t.string "login"
    t.string "password"
    t.string "path"
  end

  create_table "gateway_offline_alerts", :force => true do |t|
    t.integer  "device_id",                      :null => false
    t.integer  "number_attempts", :default => 1, :null => false
    t.datetime "reconnected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gateway_offline_alerts", ["device_id"], :name => "outage_alerts_device_id_idx"
  add_index "gateway_offline_alerts", ["device_id"], :name => "outage_alerts_outage_idx"

  create_table "gateway_online_alerts", :force => true do |t|
    t.integer  "device_id",  :null => false
    t.datetime "created_at", :null => false
  end

  add_index "gateway_online_alerts", ["device_id"], :name => "gateway_online_alerts_device_id_idx"

  create_table "gateways", :force => true do |t|
    t.string  "serial_number"
    t.string  "mac_address"
    t.string  "vendor"
    t.string  "model"
    t.string  "kind"
    t.integer "kind_id"
  end

  create_table "halo_debug_msgs", :force => true do |t|
    t.integer  "source_mote_id"
    t.datetime "timestamp"
    t.integer  "dbg_type"
    t.integer  "param1"
    t.integer  "param2"
    t.integer  "param3"
    t.integer  "param4"
    t.integer  "param5"
    t.integer  "param6"
    t.integer  "param7"
    t.integer  "param8"
    t.integer  "user_id"
  end

  create_table "latest_vitals", :force => true do |t|
    t.datetime "updated_at", :null => false
  end

  create_table "lost_datas", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_time"
    t.datetime "end_time"
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
    t.boolean  "pending",             :default => true
    t.integer  "cmd_id"
  end

  create_table "mgmt_queries", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
    t.integer  "poll_rate"
    t.integer  "mgmt_cmd_id"
  end

  create_table "mgmt_responses", :force => true do |t|
    t.integer  "mgmt_cmd_id"
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
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
    t.string  "phone_email"
    t.integer "carrier_id"
    t.string  "time_zone"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

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

  add_index "roles", ["authorizable_id"], :name => "index_roles_on_authorizable_id"

  create_table "roles_users", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "roles_users_options", :force => true do |t|
    t.integer "roles_user_id"
    t.boolean "removed",       :default => false
    t.boolean "active",        :default => false
    t.boolean "phone_active",  :default => false
    t.boolean "email_active",  :default => false
    t.boolean "text_active",   :default => false
    t.integer "position",      :default => 0
    t.string  "relationship"
  end

  create_table "skin_temps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "skin_temp", :null => false
  end

  add_index "skin_temps", ["user_id", "timestamp"], :name => "index_skin_temps_on_timestamp_and_user_id"

  create_table "steps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_timestamp"
    t.datetime "end_timestamp"
    t.integer  "steps",           :null => false
  end

  add_index "steps", ["user_id", "begin_timestamp"], :name => "index_steps_on_begin_timestamp_and_user_id"

  create_table "strap_fasteneds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "user_id"
  end

  create_table "strap_removeds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "user_id"
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
    t.string   "serial_number"
    t.string   "time_zone"
  end

  create_table "vital_scans", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
  end

  create_table "vitals", :force => true do |t|
    t.integer  "heartrate"
    t.integer  "hrv"
    t.integer  "activity"
    t.integer  "orientation"
    t.datetime "timestamp"
    t.integer  "user_id"
  end

  add_index "vitals", ["timestamp", "user_id"], :name => "index_vitals_on_timestamp_and_user_id"

end
