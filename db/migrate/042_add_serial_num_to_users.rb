class AddSerialNumToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :serial_number, :string
  end

  def self.down
    remove_column :users, :serial_number
  end
end
