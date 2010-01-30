class CreateDialUpAlerts < ActiveRecord::Migration
  def self.up
    create_table :dial_up_alerts do |t|
      t.column :id,                         :primary_key, :null => false 
  	  t.column :device_id,                  :integer
      t.column :phone_number,               :string
      t.column :username,                   :string
      t.column :password,                   :string
      t.column :alt_number,                 :string
      t.column :alt_username,               :string
      t.column :alt_password,               :string
      t.column :last_successful_number,     :string
      t.column :last_successful_username,   :string
      t.column :last_successful_password,   :string
      t.column :timestamp,                  :timestamp_with_time_zone
      t.timestamps

    end
  end

  def self.down
    drop_table :dial_up_alerts
  end
end
