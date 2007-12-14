class ModifyCallOrders < ActiveRecord::Migration
  def self.up
  	add_column :call_orders, :active, :integer, :limit => 1, :null=> false 
	add_column :call_orders, :phone_active, :integer, :limit => 1, :null=> false 
	add_column :call_orders, :email_active, :integer, :limit => 1, :null=> false 
	add_column :call_orders, :text_active, :integer, :limit => 1, :null=> false 
  end

  def self.down
  end
end
