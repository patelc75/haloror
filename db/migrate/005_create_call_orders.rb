class CreateCallOrders < ActiveRecord::Migration
  def self.up
    create_table :call_orders do |t|
      t.column :user_id, :integer
      t.column :caregiver_id, :integer      
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :call_orders
  end
end
