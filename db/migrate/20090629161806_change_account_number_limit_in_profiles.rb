class ChangeAccountNumberLimitInProfiles < ActiveRecord::Migration
  def self.up
  	change_column :profiles, :account_number, :string
  end

  def self.down
  	change_column :profiles, :account_number, :string, :limit => 4
  end
end
