class AddTimeZoneToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :time_zone, :string
  end

  def self.down
    remove_column :profiles, :time_zone
  end
end
