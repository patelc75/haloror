class AddGroupIdToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :group_id, :integer
  end

  def self.down
    remove_column :orders, :group_id
  end
end
