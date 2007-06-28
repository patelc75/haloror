class CreateHeartrates < ActiveRecord::Migration
  def self.up
    create_table :heartrates do |t|
			t.column :sessionID, :int
			t.column :timeStamp, :int
			t.column :heartRate, :int
    end
  end

  def self.down
    drop_table :heartrates
  end
end
