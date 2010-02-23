class RefactorOrderItemsForDeviceModels < ActiveRecord::Migration
  def self.up
    add_column :order_items, :device_model_id, :integer, :default => nil
    remove_column :order_items, :device_revision_id        
  end

  def self.down
    remove_column :order_items, :device_model_id
    add_column :order_items, :device_revision_id, :integer, :default => nil        
  end
end
