class CreateLostDatas < ActiveRecord::Migration
  def self.up
    create_table :lost_datas do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :begin_time, :timestamp_with_time_zone
      t.column :end_time, :timestamp_with_time_zone
      #t.timestamps
    end
  end

  def self.down
    drop_table :lost_datas
  end
end
