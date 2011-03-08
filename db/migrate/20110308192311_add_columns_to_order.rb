class AddColumnsToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :device_model_id, :integer
    add_column :orders, :cc_expiry_date, :date
    add_column :orders, :cc_deposit, :integer
    add_column :orders, :cc_shipping, :integer
    add_column :orders, :cc_monthly_recurring, :integer
    add_column :orders, :cc_months_advance, :integer
    add_column :orders, :cc_months_trial, :integer
    add_column :orders, :ship_description, :string
    add_column :orders, :ship_price, :integer
  end

  def self.down
    remove_column :orders, :cc_months_trial
    remove_column :orders, :cc_months_advance
    remove_column :orders, :cc_monthly_recurring
    remove_column :orders, :cc_shipping
    remove_column :orders, :cc_deposit
    remove_column :orders, :cc_expiry_date
    remove_column :orders, :device_model_id
    remove_column :orders, :ship_description
    remove_column :orders, :ship_price
  end
end
