class AddFieldsToRmas < ActiveRecord::Migration
  def self.up
  	add_column :rmas, :group_id, :integer
  	add_column :rmas, :status, :string
  	add_column :rmas, :user_id, :integer
  	add_column :rmas, :phone_number, :string
  end

  def self.down
  	remove_column :rmas, :group_id
  	remove_column :rmas, :status
  	remove_column :rmas, :user_id
  	remove_column :rmas, :phone_number
  end
end
