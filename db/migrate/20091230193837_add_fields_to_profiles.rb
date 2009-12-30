class AddFieldsToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :profiles,:medical_equipment_in_the_home,:string
  	add_column :profiles,:medications,:text
  	add_column :profiles,:diabetes,:boolean
  	add_column :profiles,:cancer,:boolean
  	add_column :profiles,:seizures,:boolean
  	add_column :profiles,:stroke_cva_tia,:boolean
  	add_column :profiles,:cardiac_history,:boolean
  	add_column :profiles,:pacemaker,:boolean
  	add_column :profiles,:additional_info,:text
  end

  def self.down
  	remove_column :profiles,:medical_equipment_in_the_home
  	remove_column :profiles,:medications
  	remove_column :profiles,:diabetes
  	remove_column :profiles,:cancer
  	remove_column :profiles,:seizures
  	remove_column :profiles,:stroke_cva_tia
  	remove_column :profiles,:cardiac_history
  	remove_column :profiles,:pacemaker
  	remove_column :profiles,:additional_info
  end
end
