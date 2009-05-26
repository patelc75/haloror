class AddFieldsToProfile < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :door, :string
  	add_column :profiles, :hospital_preference, :string
  	add_column :profiles, :hospital_number, :string
  	add_column :profiles, :doctor_name, :string
  	add_column :profiles, :doctor_phone, :string
  end

  def self.down
  	remove_column :profiles, :door
  	remove_column :profiles, :hospital_preference
  	remove_column :profiles, :hospital_number
  	remove_column :profiles, :doctor_name
  	remove_column :profiles, :doctor_phone
  end
end
