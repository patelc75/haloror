class CreatePanics < ActiveRecord::Migration
  def self.up
    create_table :panics do |t|
		t.column :user_id, :integer
		t.column :timestamp, :timestamp_with_time_zone
    end
  end

  def self.down
    drop_table :panics
  end
end
