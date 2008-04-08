class DropEmailFromProfiles < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :email
  end

  def self.down
  end
end
