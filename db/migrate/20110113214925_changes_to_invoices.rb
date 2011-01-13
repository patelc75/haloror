class ChangesToInvoices < ActiveRecord::Migration
  def self.up
    remove_column :invoices, :coupon_code_id
    add_column :invoices, :coupon_code, :string
  end

  def self.down
  end
end
