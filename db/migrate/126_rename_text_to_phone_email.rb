class RenameTextToPhoneEmail < ActiveRecord::Migration
  def self.up
    rename_column(:profiles, :text_email, :phone_email)
  end

  def self.down
    rename_column(:profiles, :phone_email, :text_email)
  end
end
