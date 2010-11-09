class OrdersHaveEncryptedCardCvv < ActiveRecord::Migration
  def self.up
    add_column :orders, :cvv, :string
  end

  def self.down
    remove_column :orders, :cvv
  end
end
