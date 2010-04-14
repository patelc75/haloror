class AddDuplicateIdToEvents < ActiveRecord::Migration
  def self.up
  	add_column :events,:duplicate_id,:integer
  end

  def self.down
  	remove_column :events,:duplicate_id
  end
end
