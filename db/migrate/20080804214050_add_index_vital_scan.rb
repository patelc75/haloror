class AddIndexVitalScan < ActiveRecord::Migration
  def self.up
    add_index :vital_scans, [:user_id, :timestamp]
  end

  def self.down
    remove_index :vital_scans, [:user_id, :timestamp]
  end
end
