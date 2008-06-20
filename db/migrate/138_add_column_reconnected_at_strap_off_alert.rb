class AddColumnReconnectedAtStrapOffAlert < ActiveRecord::Migration
  def self.up
    add_column :strap_off_alerts, :reconnected_at, :datetime
  end

  def self.down
    remove_column :strap_off_alerts, :reconnected_at
  end
end
