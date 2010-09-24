class UserIntakeHasDeviceAndGatewayNumbers < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :transmitter_serial, :string
    add_column :user_intakes, :gateway_serial, :string
  end

  def self.down
    remove_columns :user_intakes, :transmitter_serial, :gateway_serial
  end
end
