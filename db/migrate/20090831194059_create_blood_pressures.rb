class CreateBloodPressures < ActiveRecord::Migration
  def self.up
    create_table :blood_pressures do |t|
      t.column :id, :primary_key, :null => false 
      t.column :user_id, :integer
      t.column :timestamp, :datetime
      t.column :systolic, :integer
      t.column :diastolic, :integer
      t.column :map, :integer
      t.column :pulse, :integer
      t.column :battery, :integer
      t.column :serial_number, :string
      t.column :hw_rev, :string
      t.column :sw_rev, :string
      
      t.timestamps
      
    end
  end

  def self.down
    drop_table :blood_pressures
  end
end
