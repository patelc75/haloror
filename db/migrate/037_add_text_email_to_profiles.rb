class AddTextEmailToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :text_email, :string
  end

  def self.down
    remove_column :profiles, :text_email
  end
end