class CreateAccessLogs < ActiveRecord::Migration
  def self.up
    create_table :access_logs do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :status, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :access_logs
  end
end
