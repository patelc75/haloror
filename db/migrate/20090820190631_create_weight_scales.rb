class CreateWeightScales < ActiveRecord::Migration
  def self.up
    create_table :weight_scales do |t|
      t.column :id, :primary_key, :null => false 
      t.integer :user_id
      t.datetime :timestamp
      t.integer :weight
      t.string :weight_unit
      t.integer :bmi
      t.integer :hydration
      t.integer :battery
      t.string :serial_number
      t.string :hw_rev
      t.string :sw_rev

      t.timestamps

    end
  end

  def self.down
    drop_table :weight_scales
  end
end
