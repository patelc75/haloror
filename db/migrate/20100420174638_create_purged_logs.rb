class CreatePurgedLogs < ActiveRecord::Migration
  def self.up
    create_table :purged_logs do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :model, :string
      t.column :from_date, :timestamp
      t.column :to_date, :timestamp
      t.timestamps

    end
  end

  def self.down
    drop_table :purged_logs
  end
end
