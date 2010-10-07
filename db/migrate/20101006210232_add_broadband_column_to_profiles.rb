class AddBroadbandColumnToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :broadband, :boolean
  end

  def self.down
    remove_column :profiles, :broadband
  end
end
