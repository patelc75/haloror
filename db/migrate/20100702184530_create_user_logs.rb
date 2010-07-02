class CreateUserLogs < ActiveRecord::Migration
  def self.up
    create_table :user_logs do |t|
      t.column :id, :primary_key, :null => false 
      t.integer :user_id
      t.text :log

      t.timestamps
    end
  end

  def self.down
    drop_table :user_logs
  end
end
