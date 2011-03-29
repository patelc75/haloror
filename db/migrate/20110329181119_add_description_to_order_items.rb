class AddDescriptionToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :description, :string
  end

  def self.down
    remove_column :order_items, :description
  end
end
