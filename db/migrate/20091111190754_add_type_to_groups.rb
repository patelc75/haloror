class AddTypeToGroups < ActiveRecord::Migration
  def self.up
  	add_column :groups, :sales_type, :string
  end

  def self.down
  	remove_column :groups, :sales_type
  end
end
