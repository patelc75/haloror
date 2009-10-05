class CreateStrapNotWorns < ActiveRecord::Migration
  def self.up
    create_table :strap_not_worns do |t|
      t.column :id, :primary_key, :null => false 
      t.column :user_id, :integer
      t.column :begin_time, :datetime
      t.column :end_time, :datetime
	end
	add_index :strap_not_worns, [:user_id,:end_time,:begin_time], :unique => false
  end

  def self.down
    drop_table :strap_not_worns
  end
end
