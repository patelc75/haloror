class AddColumnToOrders2 < ActiveRecord::Migration
  def self.up
    add_column :orders, :shipping_option_id, :integer
  end

  def self.down
    remove_column :orders, :shipping_option_id
  end
end
