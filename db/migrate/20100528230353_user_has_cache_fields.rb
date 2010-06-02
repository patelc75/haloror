class UserHasCacheFields < ActiveRecord::Migration
  def self.up
    add_column :users, :last_battery_id, :integer
    add_column :users, :last_event_id, :integer
    add_column :users, :last_vital_id, :integer
    add_column :users, :last_triage_audit_log_id, :integer
    add_column :users, :has_no_panic_button_test, :boolean
    add_column :users, :has_no_strap_detected, :boolean
    add_column :users, :has_no_call_center_account, :boolean
  end

  def self.down
    remove_columns :users, :last_battery_id, :last_event_id, :last_vital_id, :last_triage_audit_log_id
    remove_columns :users, :has_no_panic_button_test, :has_no_strap_detected, :has_no_call_center_account
  end
end
