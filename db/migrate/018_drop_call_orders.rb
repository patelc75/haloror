class DropCallOrders < ActiveRecord::Migration
  def self.up
    drop_table :call_orders
  end

  def self.down
  end
end
