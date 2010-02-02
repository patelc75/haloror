class SplitNamesToFirstLastInOrder < ActiveRecord::Migration
  def self.up
    rename_column :orders, :ship_name, :ship_first_name
    rename_column :orders, :bill_name, :bill_first_name
    add_column :orders, :ship_last_name, :string
    add_column :orders, :bill_last_name, :string
  end

  def self.down
    remove_column :orders, :ship_last_name
    remove_column :orders, :bill_last_name
    rename_column :orders, :ship_first_name, :ship_name
    rename_column :orders, :bill_first_name, :bill_name
  end
end
