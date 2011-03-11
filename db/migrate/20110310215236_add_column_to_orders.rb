class AddColumnToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :dealer_install_fee_applies, :boolean
  end

  def self.down
    remove_column :orders, :dealer_install_fee_applies
  end
end
