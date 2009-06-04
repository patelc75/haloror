class AddModeToBatteryCritical < ActiveRecord::Migration
  def self.up
  add_column :battery_criticals, :mode, :string
  end

  def self.down
  remove_column :battery_criticals, :mode
  end
end
