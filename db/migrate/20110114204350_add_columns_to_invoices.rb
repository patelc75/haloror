class AddColumnsToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :prorate_start_date, :datetime
    add_column :invoices, :installed_date, :datetime
    add_column :invoices, :recurring_start_date, :datetime
    add_column :invoices, :manual_billing, :boolean
    add_column :invoices, :deposit, :decimal
    add_column :invoices, :shipping, :decimal
    add_column :invoices, :prorate, :decimal
    add_column :invoices, :recurring, :decimal
  end

  def self.down
    remove_column :invoices, :prorate_start_date
    remove_column :invoices, :installed_date
    remove_column :invoices, :recurring_start_date
    remove_column :invoices, :manual_billing
    remove_column :invoices, :deposit
    remove_column :invoices, :shipping
    remove_column :invoices, :prorate
    remove_column :invoices, :recurring
  end
end
