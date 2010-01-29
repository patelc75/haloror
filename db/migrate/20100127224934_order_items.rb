class OrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.column :id, :primary_key, :null => false # needed for pg gem migration
      t.column :device_revision_id, :integer
      t.column :order_id, :integer
      t.column :cost, :float # future orders may have multiple products in each. This serves 'sold at a value of x' purpose
      t.column :quantity, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
