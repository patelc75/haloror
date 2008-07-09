class AddCreatedByToNotes < ActiveRecord::Migration
  def self.up
    add_column :notes, :created_by, :integer
  end

  def self.down
    remove_column :notes, :created_by
  end
end
