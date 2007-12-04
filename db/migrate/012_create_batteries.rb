class CreateBatteries < ActiveRecord::Migration
  def self.up
    create_table :batteries do |t|
      t.column :user_id, :integer
      t.column :timestamp, :timestamp
      t.column :percentage, :integer
    end
  end

  def self.down
    drop_table :batteries
  end
end
