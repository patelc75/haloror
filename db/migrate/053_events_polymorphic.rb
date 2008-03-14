class EventsPolymorphic < ActiveRecord::Migration
  def self.up
    remove_column :events, :kind
    remove_column :events, :kind_id
    
    add_column :events, :event_type, :string
    add_column :events, :event_id, :integer
  end

  def self.down
    add_column :events, :kind, :string
    add_column :events, :kind_id, :integer
    
    remove_column :events, :event_type
    remove_column :events, :event_id
  end
end
