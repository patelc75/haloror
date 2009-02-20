class AddSaltToGatewayPassword < ActiveRecord::Migration
  def self.up
    add_column :gateway_passwords, :salt, :string
  end

  def self.down
    remove_column :gateway_passwords, :salt
  end
end
