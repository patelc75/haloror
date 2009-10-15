class AddFieldsToVitalsPanicsBatteries < ActiveRecord::Migration
  def self.up
  	add_column :panics, :duration_press, :integer
  	add_column :vitals, :strap_status, :boolean
  	add_column :batteries, :acpower_status, :boolean
  	add_column :batteries, :charge_status, :boolean
  end

  def self.down
  	remove_column :panics, :duration_press
  	remove_column :vitals, :strap_status
  	remove_column :batteries, :acpower_status
  	remove_column :batteries, :charge_status
  end
end
