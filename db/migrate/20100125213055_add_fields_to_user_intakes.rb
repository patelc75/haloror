class AddFieldsToUserIntakes < ActiveRecord::Migration
  def self.up
  	add_column :user_intakes,:credit_debit_card_proceessed,:boolean
  	add_column :user_intakes,:bill_monthly,:boolean
  	add_column :user_intakes,:kit_serial_number,:string
  	remove_column :profiles,:credit_debit_card_proceessed
  	remove_column :profiles,:bill_monthly
  end

  def self.down
  	remove_column :user_intakes,:credit_debit_card_proceessed
  	remove_column :user_intakes,:bill_monthly
  	remove_column :user_intakes,:kit_serial_number
  	add_column :profiles,:credit_debit_card_proceessed,:boolean
  	add_column :profiles,:bill_monthly,:boolean
  end
end
