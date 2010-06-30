class ProfileVoipPhone < ActiveRecord::Migration
  def self.up
    add_column :profiles, :voip_phone, :boolean
  end

  def self.down
    remove_column :profiles, :voip_phone, :boolean
  end
end
