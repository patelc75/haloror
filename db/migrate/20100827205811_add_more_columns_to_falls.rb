class AddMoreColumnsToFalls < ActiveRecord::Migration
  def self.up
    add_column :falls, :severity, :integer
  end

  def self.down
    drop_column :falls, :severity
  end
end
