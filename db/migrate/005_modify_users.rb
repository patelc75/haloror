class ModifyUsers < ActiveRecord::Migration
  def self.up
	add_column :users, :type, :string
	
	add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :home_phone, :string
    add_column :users, :work_phone, :string
    add_column :users, :cell_phone, :string
    add_column :users, :relationship, :string
  end

  def self.down
	remove_column :users, :type

	remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :address
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :home_phone
    remove_column :users, :work_phone
    remove_column :users, :cell_phone
    remove_column :users, :relationship
  end
end
