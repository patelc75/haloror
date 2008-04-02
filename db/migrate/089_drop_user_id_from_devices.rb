class DropUserIdFromDevices < ActiveRecord::Migration
  def self.up
    remove_column :devices, :user_id
  end

  def self.down
    add_column :devices, :user_id, :integer
  end
end
