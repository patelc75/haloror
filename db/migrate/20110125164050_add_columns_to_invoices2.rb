class AddColumnsToInvoices2 < ActiveRecord::Migration
  def self.up 
    add_column :invoices, :cancelled_date, :datetime    
  end

  def self.down         
    remove_column :invoices, :cancelled_date    
  end
end
