class AddRecurringBooleanToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :recurring_monthly, :boolean    
  end

  def self.down
    remove_column :order_items, :recurring_monthly
  end
end
t