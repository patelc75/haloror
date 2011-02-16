class SwitchDecimalToFloat < ActiveRecord::Migration
  def self.up
    change_column :invoices, :kit_charged, :float
    change_column :invoices, :install_fee_amount, :float
    change_column :invoices, :affiliate_fee_amount, :float
    change_column :invoices, :referral_amount, :float
    change_column :invoices, :deposit, :float
    change_column :invoices, :shipping, :float
    change_column :invoices, :prorate, :float
    change_column :invoices, :recurring, :float
  end

  def self.down
    # nothing to shift here
    # WARNING: Subscription table also has a :decimal column. acts_as_audited does not work with :decimal
  end
end
