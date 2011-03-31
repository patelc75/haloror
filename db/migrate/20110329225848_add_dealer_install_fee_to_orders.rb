class AddDealerInstallFeeToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :cc_dealer_install_fee, :float
  end

  def self.down
    remove_column :orders, :cc_dealer_install_fee
  end
end
