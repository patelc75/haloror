class AddDialUpNumToAccessMode < ActiveRecord::Migration
  def self.up
    add_column :access_modes, :number, :string
  end

  def self.down
	remove_column :access_modes, :number
  end
end
