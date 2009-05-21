class AddAccountNumberToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :account_number, :string, :limit => 4
  end

  def self.down
    remove_column :profiles, :account_number
  end
end
