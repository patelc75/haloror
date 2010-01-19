class CreateDialUpStatuses < ActiveRecord::Migration
  def self.up
    create_table :dial_up_statuses do |t|
      t.column :id, :primary_key, :null => false
      t.integer :device_id

      t.string :phone_number

      t.string :status

      t.string :configured

      t.integer :num_failures

      t.integer :consecutive_fails

      t.boolean :ever_connected

      t.string :dialup_type


      t.timestamps

    end
  end

  def self.down
    drop_table :dial_up_statuses
  end
end
