class AddNewCallCenterFields < ActiveRecord::Migration
  def self.up
    add_column :profiles, :allergies, :text
    add_column :profiles, :pet_information, :text
    
    add_column :alert_options, :is_keyholder, :boolean
    add_column :roles_users_options, :is_keyholder, :boolean
    
    add_column :profiles, :access_information, :text
  end

  def self.down
    remove_column :profiles, :access_information
    
    remove_column :roles_users_options, :is_keyholder
    remove_column :alert_options, :is_keyholder
    
    remove_column :profiles, :pet_information
    remove_column :profiles, :allergies
  end
end
