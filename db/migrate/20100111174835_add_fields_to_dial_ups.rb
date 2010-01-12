class AddFieldsToDialUps < ActiveRecord::Migration
  def self.up
  	add_column :dial_ups,:username,:text
  	add_column :dial_ups,:password,:text
  	add_column :dial_ups,:city,:text
  	add_column :dial_ups,:state,:text
  	add_column :dial_ups,:zip,:text
  	add_column :dial_ups,:dialup_type,:text
  	add_column :dial_ups,:order_number,:integer
  	add_column :dial_ups,:created_by,:integer
  	add_column :dial_ups,:created_at,:timestamp
  	add_column :dial_ups,:updated_at,:timestamp
  	change_column :dial_ups,:phone_number,:text
  	add_column :mgmt_cmds,:param4,:text
  end

  def self.down
  	remove_column :dial_ups,:username
  	remove_column :dial_ups,:password
  	remove_column :dial_ups,:city
  	remove_column :dial_ups,:state
  	remove_column :dial_ups,:zip
  	remove_column :dial_ups,:dialup_type
  	remove_column :dial_ups,:order_number
  	remove_column :dial_ups,:created_by
  	remove_column :dial_ups,:created_at
  	remove_column :dial_ups,:updated_at
  	change_column :dial_ups,:phone_number,:integer
  	remove_column :mgmt_cmds,:param4
  end
end
