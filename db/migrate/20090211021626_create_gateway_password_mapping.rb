class CreateGatewayPasswordMapping < ActiveRecord::Migration
  def self.up
    create_table :gateway_passwords, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer, :null => false
      t.column :password, :string, :null => false
    end
  end

  def self.down
    drop_table :gateway_password
  end
end
