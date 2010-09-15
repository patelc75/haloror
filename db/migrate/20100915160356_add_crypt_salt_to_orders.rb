class AddCryptSaltToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :salt, :string
  end

  def self.down
    remove_column :orders, :salt
  end
end
