class CreateNotesForStartRangeTest < ActiveRecord::Migration
  def self.up
    create_table :installation_notes, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer, :null => false
      t.column :notes, :text
      t.timestamps
    end
  end

  def self.down
  end
end
