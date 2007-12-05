class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
		t.column :user_id, :integer
		t.column :kind, :string
		t.column :kind_id, :integer		
    end
  end

  def self.down
    drop_table :events
  end
end
