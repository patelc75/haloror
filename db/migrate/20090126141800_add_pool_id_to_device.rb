class AddPoolIdToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :pool_id, :integer
  end

  def self.down
    remove_column :devices, :pool_id
  end
end
