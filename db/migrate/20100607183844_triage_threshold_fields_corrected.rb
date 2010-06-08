class TriageThresholdFieldsCorrected < ActiveRecord::Migration
  def self.up
    change_table :triage_thresholds do |t|
      # t.remove :has_no_panic_button_test, :has_no_strap_detected, :has_no_call_center_account
      t.column :hours_without_panic_button_test, :integer
      t.column :hours_without_strap_detected, :integer
      t.column :hours_without_call_center_account, :integer
    end
  end

  def self.down
    remove_column :triage_thresholds, :hours_without_panic_button_test
    remove_column :triage_thresholds, :hours_without_strap_detected
    remove_column :triage_thresholds, :hours_without_call_center_account
  end
end
