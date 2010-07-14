class AddGwTimestampToFallAndPanic < ActiveRecord::Migration
  def self.up
    add_column :falls, :gw_timestamp, :datetime
    add_column :panics, :gw_timestamp, :datetime
  end

  def self.down
    remove_column :falls, :gw_timestamp
    remove_column :panics, :gw_timestamp
  end
end
