class AddNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
	    t.column :id, :primary_key, :null => false 
	    t.column :user_id, :integer
	    t.column :event_id, :integer
      t.column :created_at, :datetime
      t.column :notes, :text
    end
  end

  def self.down
    drop_table :notes
  end
end
