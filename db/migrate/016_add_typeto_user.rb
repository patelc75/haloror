class AddTypetoUser < ActiveRecord::Migration
  def self.up
  	add_column :users, :type, :string
  end

  def self.down
  end
end
