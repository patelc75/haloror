class CreateEventActions < ActiveRecord::Migration
  def self.up
    create_table :event_actions do |t|
      t.column :user_id, :integer
      t.column :event_id, :integer
      t.column :description, :string      
      t.timestamps
    end
  end

  def self.down
    drop_table :event_actions
  end
end
