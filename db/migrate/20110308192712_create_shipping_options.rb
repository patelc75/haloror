class CreateShippingOptions < ActiveRecord::Migration
  def self.up
    create_table :shipping_options do |t|
      t.column :id, :primary_key, :null => false
      t.column :description, :string
      t.column :price, :integer
      t.column :order_id, :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_options
  end
end
