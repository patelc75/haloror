class CreateDeviceModelPrices < ActiveRecord::Migration
  def self.up
    create_table :device_model_prices do |t|
      t.column :id, :primary_key, :null => false
      t.references :device_model
      t.string :coupon_code
      t.date :expiry_date
      t.integer :deposit
      t.integer :shipping
      t.integer :monthly_recurring
      t.integer :months_advance
      t.integer :months_trial

      t.timestamps
    end
  end

  def self.down
    drop_table :device_model_prices
  end
end
