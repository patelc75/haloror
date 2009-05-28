class AddFieldsToCustomerProfile < ActiveRecord::Migration
  def self.up
  	add_column :profiles, :sex, :string, :limit => 1
  	add_column :profiles, :birth_date, :date
  end

  def self.down
  	remove_column :profiles, :sex
  	remove_column :profiles, :birth_date
  end
end
