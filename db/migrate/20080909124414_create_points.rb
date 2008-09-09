class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.column :id, :primary_key, :null => false
      t.integer :seq
      t.integer :data
      t.integer :oscope_msg_id
    end
  end

  def self.down
    drop_table :points
  end
end
