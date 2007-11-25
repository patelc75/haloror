class CreateFalls < ActiveRecord::Migration
  def self.up
    create_table :falls do |t|
		t.column :user_id, :integer
		t.column :timestamp, :timestamp_with_time_zone
		t.column :magnitude, :integer, :limit => 2, :null=> false #will use smallint becuase of plug-in
    end
  end

  def self.down
    drop_table :falls
  end
end
