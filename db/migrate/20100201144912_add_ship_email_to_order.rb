class AddShipEmailToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :ship_email, :string
  end

  def self.down
    remove_column :orders, :ship_email
  end
end
