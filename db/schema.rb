# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100608152525) do

  create_table "access_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_logs", ["user_id"], :name => "index_access_logs_on_user_id"

  create_table "access_mode_statuses", :force => true do |t|
    t.integer "device_id"
    t.string  "mode"
  end

  create_table "access_modes", :force => true do |t|
    t.integer  "device_id"
    t.string   "mode"
    t.datetime "timestamp"
    t.string   "number"
  end

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
    t.string   "alert_type"
    t.boolean  "phone_active"
    t.boolean  "email_active"
    t.boolean  "text_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deprecated"
  end

  create_table "atp_item_results", :force => true do |t|
    t.integer  "atp_item_id"
    t.boolean  "result"
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "operator_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
    t.string   "result_value",       :limit => 1024
    t.integer  "atp_test_result_id"
  end

  create_table "atp_items", :force => true do |t|
    t.integer  "range_low"
    t.integer  "range_high"
    t.string   "description"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
    t.string   "atp_key"
  end

  create_table "atp_items_device_revisions", :force => true do |t|
    t.integer "atp_item_id",        :null => false
    t.integer "device_revision_id", :null => false
  end

  create_table "atp_test_results", :force => true do |t|
    t.boolean  "result"
    t.integer  "device_id"
    t.integer  "operator_id"
    t.datetime "timestamp"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
  end

  create_table "atp_test_results_rmas", :id => false, :force => true do |t|
    t.integer  "atp_test_result_id"
    t.integer  "rma_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
  end

  create_table "atp_test_results_work_orders", :id => false, :force => true do |t|
    t.integer  "atp_test_result_id"
    t.integer  "work_order_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.string   "ip",             :limit => 40
    t.string   "url"
    t.string   "referer"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",                      :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "batteries", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "device_id"
    t.boolean  "acpower_status"
    t.boolean  "charge_status"
  end

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
    t.integer  "percentage",       :null => false
    t.integer  "time_remaining",   :null => false
    t.integer  "user_id"
    t.string   "mode"
    t.datetime "timestamp_server"
  end

  add_index "battery_criticals", ["device_id"], :name => "index_battery_criticals_on_device_id"

  create_table "battery_pluggeds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "user_id"
  end

  add_index "battery_pluggeds", ["device_id", "timestamp"], :name => "index_battery_pluggeds_on_device_id_and_timestamp"

  create_table "battery_reminders", :force => true do |t|
    t.integer  "reminder_num"
    t.integer  "user_id"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "stopped_at"
    t.integer  "time_remaining"
    t.integer  "battery_critical_id"
  end

  create_table "battery_unpluggeds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "percentage",     :null => false
    t.integer  "time_remaining", :null => false
    t.integer  "user_id"
  end

  add_index "battery_unpluggeds", ["device_id", "timestamp"], :name => "index_battery_unpluggeds_on_device_id_and_timestamp"

  create_table "blood_pressures", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "systolic"
    t.integer  "diastolic"
    t.integer  "map"
    t.integer  "pulse"
    t.integer  "battery"
    t.string   "serial_number"
    t.string   "hw_rev"
    t.string   "sw_rev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percentage"
  end

  create_table "call_center_deferreds", :force => true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "call_center_session_id"
    t.datetime "timestamp"
    t.boolean  "pending"
  end

  create_table "call_center_faqs", :force => true do |t|
    t.text     "faq_text"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_center_follow_ups", :force => true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "call_center_session_id"
    t.datetime "timestamp"
  end

  create_table "call_center_sessions", :force => true do |t|
    t.integer  "event_id"
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  create_table "call_center_steps", :force => true do |t|
    t.text     "instruction"
    t.text     "script"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.text     "header"
    t.string   "question_key"
    t.text     "notes"
    t.boolean  "answer"
    t.integer  "call_center_session_id"
    t.integer  "call_center_group_id"
    t.integer  "previous_call_center_step_id"
    t.integer  "user_id"
  end

  create_table "call_center_wizards", :force => true do |t|
    t.integer  "event_id"
    t.integer  "operator_id"
    t.integer  "user_id"
    t.integer  "call_center_session_id"
    t.datetime "updated_at"
    t.datetime "created_at"
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

  create_table "device_battery_reminders", :force => true do |t|
    t.integer  "reminder_num"
    t.datetime "stopped_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "device_id"
    t.integer  "user_id"
    t.integer  "time_remaining"
    t.integer  "battery_critical_id"
  end

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

  add_index "device_infos", ["device_id"], :name => "index_device_infos_on_device_id"

  create_table "device_latest_queries", :force => true do |t|
    t.datetime "updated_at",     :null => false
    t.datetime "reconnected_at"
  end

  add_index "device_latest_queries", ["updated_at"], :name => "device_latest_queries_updated_at_idx"

  create_table "device_model_prices", :force => true do |t|
    t.integer  "device_model_id"
    t.string   "coupon_code"
    t.date     "expiry_date"
    t.integer  "deposit"
    t.integer  "shipping"
    t.integer  "monthly_recurring"
    t.integer  "months_advance"
    t.integer  "months_trial"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_models", :force => true do |t|
    t.integer  "device_type_id"
    t.string   "part_number"
    t.string   "model"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
  end

  create_table "device_revisions", :force => true do |t|
    t.integer  "device_model_id"
    t.string   "revision"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
    t.boolean  "online_store"
  end

  create_table "device_revisions_work_orders", :force => true do |t|
    t.integer  "work_order_id"
    t.integer  "device_revision_id"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
  end

  create_table "device_strap_status", :force => true do |t|
    t.integer  "is_fastened", :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "device_types", :force => true do |t|
    t.string   "device_type"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
    t.integer  "mac_address_type"
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
    t.string  "serial_number"
    t.boolean "active"
    t.string  "mac_address"
    t.integer "device_revision_id"
    t.integer "work_order_id"
    t.integer "pool_id"
  end

  create_table "devices_kits", :id => false, :force => true do |t|
    t.integer "kit_id",    :null => false
    t.integer "device_id", :null => false
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

  create_table "dial_up_alerts", :force => true do |t|
    t.integer  "device_id"
    t.string   "phone_number"
    t.string   "username"
    t.string   "password"
    t.string   "alt_number"
    t.string   "alt_username"
    t.string   "alt_password"
    t.string   "last_successful_number"
    t.string   "last_successful_username"
    t.string   "last_successful_password"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dial_up_last_successfuls", :force => true do |t|
    t.integer  "device_id"
    t.string   "last_successful_number"
    t.string   "last_successful_username"
    t.string   "last_successful_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dial_up_statuses", :force => true do |t|
    t.integer  "device_id"
    t.string   "phone_number"
    t.string   "status"
    t.string   "configured"
    t.integer  "num_failures"
    t.integer  "consecutive_fails"
    t.boolean  "ever_connected"
    t.string   "dialup_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dial_ups", :force => true do |t|
    t.text     "phone_number"
    t.text     "username"
    t.text     "password"
    t.text     "city"
    t.text     "state"
    t.text     "zip"
    t.text     "dialup_type"
    t.integer  "order_number"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "emergency_numbers", :force => true do |t|
    t.string  "name"
    t.string  "number"
    t.integer "group_id"
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
    t.datetime "timestamp_server"
    t.datetime "call_center_response"
    t.integer  "duplicate_id"
  end

  add_index "events", ["timestamp", "user_id"], :name => "index_events_on_user_id_and_timestamp"

  create_table "falls", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "magnitude",             :null => false
    t.integer  "device_id"
    t.datetime "timestamp_call_center"
    t.boolean  "call_center_pending"
    t.datetime "timestamp_server"
  end

  create_table "firmware_upgrades", :force => true do |t|
    t.integer "ftp_id"
    t.string  "version"
    t.string  "filename"
    t.text    "description"
    t.date    "date_added"
    t.string  "path"
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

  create_table "gateway_passwords", :force => true do |t|
    t.integer "device_id", :null => false
    t.string  "password",  :null => false
    t.string  "salt"
  end

  create_table "gateways", :force => true do |t|
    t.string  "serial_number"
    t.string  "mac_address"
    t.string  "vendor"
    t.string  "model"
    t.string  "kind"
    t.integer "kind_id"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "sales_type"
    t.string   "email"
  end

  create_table "gw_alarm_button_timeouts", :force => true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "timestamp"
    t.boolean  "pending"
    t.string   "event_type"
  end

  create_table "gw_alarm_buttons", :force => true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.datetime "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "timestamp_call_center"
    t.boolean  "call_center_pending"
    t.datetime "timestamp_server"
  end

  create_table "installation_notes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kit_serial_numbers", :force => true do |t|
    t.text     "serial_number"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kits", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "latest_vitals", :force => true do |t|
    t.datetime "updated_at", :null => false
  end

  create_table "lost_datas", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_time"
    t.datetime "end_time"
  end

  add_index "lost_datas", ["begin_time", "end_time", "user_id"], :name => "index_lost_datas_on_user_id_and_end_time_and_begin_time"

  create_table "mgmt_cmds", :force => true do |t|
    t.integer  "device_id"
    t.integer  "user_id"
    t.string   "cmd_type"
    t.datetime "timestamp_initiated"
    t.datetime "timestamp_sent"
    t.string   "originator"
    t.boolean  "pending",             :default => true
    t.integer  "cmd_id"
    t.integer  "mgmt_response_id"
    t.integer  "attempts_no_ack"
    t.boolean  "pending_on_ack"
    t.integer  "created_by"
    t.string   "param1"
    t.string   "param2"
    t.string   "param3"
    t.text     "param4"
    t.boolean  "instantaneous"
  end

  add_index "mgmt_cmds", ["device_id", "originator"], :name => "index_mgmt_cmds_on_device_id_and_originator"

  create_table "mgmt_queries", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
    t.integer  "poll_rate"
    t.integer  "mgmt_cmd_id"
    t.integer  "cycle_num"
  end

  add_index "mgmt_queries", ["device_id", "timestamp_server"], :name => "index_mgmt_queries_on_device_id_and_timestamp_server"

  create_table "mgmt_responses", :force => true do |t|
    t.datetime "timestamp_device"
    t.datetime "timestamp_server"
  end

  add_index "mgmt_responses", ["timestamp_server"], :name => "index_mgmt_responses_on_timestamp_server"

  create_table "notes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.text     "notes"
    t.integer  "created_by"
  end

  create_table "order_items", :force => true do |t|
    t.integer  "order_id"
    t.float    "cost"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "recurring_monthly"
    t.integer  "device_model_id"
  end

  create_table "orders", :force => true do |t|
    t.string   "number"
    t.string   "bill_first_name"
    t.text     "bill_address"
    t.string   "bill_city"
    t.string   "bill_state"
    t.string   "bill_zip"
    t.string   "bill_phone"
    t.string   "bill_email"
    t.float    "cost"
    t.string   "card_number"
    t.date     "card_expiry"
    t.text     "comments"
    t.boolean  "halouser"
    t.string   "ship_first_name"
    t.text     "ship_address"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip"
    t.string   "ship_phone"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ship_email"
    t.string   "card_type"
    t.string   "ship_last_name"
    t.string   "bill_last_name"
    t.integer  "group_id"
    t.string   "coupon_code"
    t.string   "kit_serial"
  end

  create_table "oscope_msgs", :force => true do |t|
    t.datetime "timestamp"
    t.integer  "channel_num"
    t.integer  "user_id"
    t.integer  "oscope_start_msg_id"
    t.integer  "oscope_stop_msg_id"
  end

  create_table "oscope_start_msgs", :force => true do |t|
    t.string   "capture_reason"
    t.integer  "source_mote_id"
    t.datetime "timestamp"
    t.integer  "user_id"
  end

  create_table "panics", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "device_id"
    t.integer  "duration_press"
    t.datetime "timestamp_call_center"
    t.boolean  "call_center_pending"
    t.datetime "timestamp_server"
  end

  create_table "payment_gateway_responses", :force => true do |t|
    t.string   "action"
    t.integer  "order_id"
    t.integer  "amount"
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "request_data"
    t.text     "request_headers"
  end

  create_table "points", :force => true do |t|
    t.integer "seq"
    t.integer "data"
    t.integer "oscope_msg_id"
  end

  create_table "pool_mappings", :force => true do |t|
    t.string   "serail_number", :null => false
    t.string   "mac_address",   :null => false
    t.integer  "pool_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pools", :force => true do |t|
    t.integer  "size",                   :null => false
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "starting_serial_number"
    t.string   "ending_serial_number"
    t.string   "starting_mac_address"
    t.string   "ending_mac_address"
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
    t.string  "zipcode"
    t.integer "emergency_number_id"
    t.text    "allergies"
    t.text    "pet_information"
    t.text    "access_information"
    t.string  "account_number"
    t.string  "door"
    t.string  "hospital_preference"
    t.string  "hospital_number"
    t.string  "doctor_name"
    t.string  "doctor_phone"
    t.string  "sex",                           :limit => 1
    t.date    "birth_date"
    t.string  "home_phone_order"
    t.string  "work_phone_order"
    t.string  "cell_phone_order"
    t.string  "other_phone_order"
    t.string  "other_phone"
    t.string  "medical_equipment_in_the_home"
    t.text    "medications"
    t.boolean "diabetes"
    t.boolean "cancer"
    t.boolean "seizures"
    t.boolean "stroke_cva_tia"
    t.boolean "cardiac_history"
    t.boolean "pacemaker"
    t.text    "additional_info"
    t.string  "cross_st"
    t.boolean "internet_access_at_home"
    t.boolean "permission_to_break_door"
    t.string  "police"
    t.string  "fire"
    t.string  "ambulance"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "purged_logs", :force => true do |t|
    t.integer  "user_id"
    t.string   "model"
    t.datetime "from_date"
    t.datetime "to_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_data_files", :force => true do |t|
    t.string   "filename"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "parent_id"
    t.datetime "created_at"
  end

  create_table "recurring_charges", :force => true do |t|
    t.integer  "group_id"
    t.float    "charge"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rma_items", :force => true do |t|
    t.string   "original_serial"
    t.string   "replacement_serial"
    t.string   "shipped_serial"
    t.string   "status"
    t.string   "redmine_ticket"
    t.string   "atp_status"
    t.datetime "shipped_on"
    t.datetime "reinstalled_on"
    t.datetime "completed_on"
    t.datetime "received_on"
    t.datetime "atp_on"
    t.text     "repair_action"
    t.text     "reason_for_return"
    t.text     "condition_of_return"
    t.text     "notes"
    t.integer  "rma_id"
    t.integer  "device_model_id"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rmas", :force => true do |t|
    t.datetime "completed_on"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
    t.integer  "group_id"
    t.string   "status"
    t.integer  "user_id"
    t.string   "phone_number"
    t.string   "serial_number"
    t.string   "related_rma"
    t.string   "redmine_ticket"
    t.string   "service_outage"
    t.string   "ship_name"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zipcode"
    t.text     "ship_address"
    t.text     "notes"
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
    t.boolean "is_keyholder",  :default => false
  end

  create_table "self_test_item_results", :force => true do |t|
    t.string   "description"
    t.boolean  "result"
    t.string   "result_value"
    t.integer  "device_id"
    t.integer  "operator_id"
    t.datetime "timestamp",           :null => false
    t.integer  "self_test_result_id"
  end

  create_table "self_test_results", :force => true do |t|
    t.boolean  "result",    :null => false
    t.string   "cmd_type",  :null => false
    t.integer  "device_id", :null => false
    t.datetime "timestamp", :null => false
  end

  create_table "self_test_sessions", :force => true do |t|
    t.datetime "created_at"
    t.integer  "created_by"
    t.integer  "user_id"
    t.datetime "completed_on"
  end

  create_table "self_test_step_descriptions", :force => true do |t|
    t.string "description"
  end

  create_table "self_test_steps", :force => true do |t|
    t.datetime "timestamp"
    t.integer  "user_id"
    t.integer  "halo_user_id"
    t.integer  "self_test_step_description_id"
    t.integer  "self_test_session_id"
    t.string   "notes"
  end

  create_table "serial_number_prefixes", :force => true do |t|
    t.string   "prefix",         :null => false
    t.integer  "device_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skin_temps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.float    "skin_temp", :null => false
  end

  create_table "steps", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_timestamp"
    t.datetime "end_timestamp"
    t.integer  "steps",           :null => false
  end

  add_index "steps", ["begin_timestamp", "steps", "user_id"], :name => "index_steps_on_user_id_and_begin_timestamp_and_steps"
  add_index "steps", ["id"], :name => "steps_pkey"

  create_table "strap_fasteneds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "user_id"
  end

  create_table "strap_not_worn_scans", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
  end

  add_index "strap_not_worn_scans", ["timestamp", "user_id"], :name => "index_strap_not_worn_scans_on_user_id_and_timestamp"

  create_table "strap_not_worns", :force => true do |t|
    t.integer  "user_id"
    t.datetime "begin_time"
    t.datetime "end_time"
  end

  add_index "strap_not_worns", ["begin_time", "end_time", "user_id"], :name => "index_strap_not_worns_on_user_id_and_end_time_and_begin_time"

  create_table "strap_off_alerts", :force => true do |t|
    t.integer  "device_id",                      :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "update_at"
    t.integer  "number_attempts", :default => 1, :null => false
    t.datetime "reconnected_at"
  end

  add_index "strap_off_alerts", ["device_id"], :name => "index_strap_off_alerts_on_device_id"

  create_table "strap_on_alerts", :force => true do |t|
    t.integer  "device_id",  :null => false
    t.datetime "created_at", :null => false
  end

  add_index "strap_on_alerts", ["device_id"], :name => "index_strap_on_alerts_on_device_id"

  create_table "strap_removeds", :force => true do |t|
    t.integer  "device_id"
    t.datetime "timestamp"
    t.integer  "user_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "arb_subscriptionId"
    t.integer  "senior_user_id"
    t.integer  "subscriber_user_id"
    t.integer  "cc_last_four"
    t.decimal  "bill_amount"
    t.string   "bill_to_first_name"
    t.string   "bill_to_last_name"
    t.date     "bill_start_date"
    t.text     "special_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_timeouts", :force => true do |t|
    t.string   "mode"
    t.integer  "gateway_offline_timeout_sec"
    t.integer  "device_unavailable_timeout_sec"
    t.integer  "strap_off_timeout_sec"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "critical_event_delay_sec"
    t.integer  "battery_reminder_two_sec"
    t.integer  "battery_reminder_three_sec"
    t.integer  "gateway_offline_offset_sec"
  end

  create_table "triage_audit_logs", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "is_dismissed"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "triage_thresholds", :force => true do |t|
    t.integer  "group_id"
    t.string   "status"
    t.integer  "battery_percent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hours_without_panic_button_test"
    t.integer  "hours_without_strap_detected"
    t.integer  "hours_without_call_center_account"
  end

  create_table "user_intakes", :force => true do |t|
    t.date     "installation_date"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "credit_debit_card_proceessed"
    t.boolean  "bill_monthly"
    t.string   "kit_serial_number"
    t.integer  "order_id"
    t.integer  "group_id"
    t.boolean  "subscriber_is_user"
    t.boolean  "subscriber_is_caregiver"
    t.boolean  "locked",                       :default => false
  end

  create_table "user_intakes_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "user_intake_id"
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
    t.string   "serial_number"
    t.string   "time_zone"
    t.integer  "created_by"
    t.integer  "last_battery_id"
    t.integer  "last_event_id"
    t.integer  "last_vital_id"
    t.integer  "last_triage_audit_log_id"
    t.integer  "last_panic_id"
    t.integer  "last_strap_fastened_id"
  end

  create_table "vital_scans", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
  end

  add_index "vital_scans", ["timestamp", "user_id"], :name => "index_vital_scans_on_user_id_and_timestamp"

  create_table "vitals", :force => true do |t|
    t.integer  "heartrate"
    t.integer  "hrv"
    t.integer  "activity"
    t.integer  "orientation"
    t.datetime "timestamp"
    t.integer  "user_id"
    t.boolean  "strap_status"
  end

  create_table "weight_scales", :force => true do |t|
    t.integer  "user_id"
    t.datetime "timestamp"
    t.integer  "weight"
    t.string   "weight_unit"
    t.integer  "bmi"
    t.integer  "hydration"
    t.integer  "battery"
    t.string   "serial_number"
    t.string   "hw_rev"
    t.string   "sw_rev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "percentage"
  end

  create_table "work_orders", :force => true do |t|
    t.datetime "completed_on"
    t.string   "work_order_num"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.integer  "created_by"
    t.string   "comments"
  end

end
