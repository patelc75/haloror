class AddColumnsToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :home_phone_order, :integer
  	add_column :profiles, :work_phone_order, :integer
  	add_column :profiles, :cell_phone_order, :integer
  	add_column :profiles, :other_phone_order, :integer
  	add_column :profiles, :other_phone, :integer
  end

  def self.down
  	remove_column :profiles, :home_phone_order
  	remove_column :profiles, :work_phone_order
  	remove_column :profiles, :cell_phone_order
  	remove_column :profiles, :other_phone_order
  	remove_column :profiles, :other_phone
  end
end
