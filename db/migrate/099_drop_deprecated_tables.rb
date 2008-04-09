class DropDeprecatedTables < ActiveRecord::Migration
  def self.up
    drop_table :heartrates
    drop_table :orientations
    drop_table :activities
  end

  def self.down
  end
end
