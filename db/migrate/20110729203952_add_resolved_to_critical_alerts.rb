class AddResolvedToCriticalAlerts < ActiveRecord::Migration
  def self.up
    add_column :falls, :resloved, :string
    add_column :panics, :resloved, :string
  end

  def self.down
    drop_column :falls, :resloved
    drop_column :panics, :resloved
  end
end

