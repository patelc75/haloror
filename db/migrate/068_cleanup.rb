class Cleanup < ActiveRecord::Migration
  def self.up
    drop_table :alerts
    
    remove_column :events, :level
  end

  def self.down
    create_table :alerts
    
    add_column :events, :level
  end
end
