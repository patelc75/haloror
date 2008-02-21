class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :serial_number, :string
      #t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
