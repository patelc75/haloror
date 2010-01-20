class AddExtraFieldsToProfiles < ActiveRecord::Migration
  def self.up
  	add_column :profiles,:internet_access_at_home,:boolean
  	add_column :profiles,:credit_debit_card_proceessed,:boolean
  	add_column :profiles,:bill_monthly,:boolean
  	add_column :profiles,:permission_to_break_door,:boolean
  	add_column :profiles,:police,:string
  	add_column :profiles,:fire,:string
  	add_column :profiles,:ambulance,:string
  	
  end

  def self.down
  	remove_column :profiles,:internet_access_at_home
  	remove_column :profiles,:credit_debit_card_proceessed
  	remove_column :profiles,:bill_monthly
  	remove_column :profiles,:permission_to_break_door
  	remove_column :profiles,:police
  	remove_column :profiles,:fire
  	remove_column :profiles,:ambulance
  end
end
