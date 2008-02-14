class DropCallOrders < ActiveRecord::Migration
  def self.up
    drop_table :call_orders
  end

  def self.down
    create_table :call_orders do |t|
      t.column :id, :primary_key, :null => false 
      t.column :user_id, :integer
      t.column :caregiver_id, :integer      
      t.column :position, :integer
      t.column :active, :integer, :limit => 1, :null=> false 
      t.column :phone_active, :integer, :limit => 1, :null=> false 
      t.column :email_active, :integer, :limit => 1, :null=> false 
      t.column :text_active, :integer, :limit => 1, :null=> false 
    end
  end
end
