class AddLevelToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :level, :string
  end

  def self.down
    remove_column :events, :level
  end
end
