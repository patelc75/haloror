class CreateTriageThresholds < ActiveRecord::Migration
  def self.up
    create_table :triage_thresholds do |t|
      t.column :id, :primary_key, :null => false
      t.column :group_id, :integer
      t.column :status, :string
      t.column :battery_percent, :integer
      t.column :has_no_panic_button_test, :boolean
      t.column :has_no_strap_detected, :boolean
      t.column :has_no_call_center_account, :boolean

      t.timestamps
    end
  end

  def self.down
    drop_table :triage_thresholds
  end
end
