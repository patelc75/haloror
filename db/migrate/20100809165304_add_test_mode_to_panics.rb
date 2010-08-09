class AddTestModeToPanics < ActiveRecord::Migration
  def self.up
    add_column :panics, :test_mode, :boolean
    add_column :users,  :test_mode, :boolean
  end

  def self.down
    remove_columns :panics, :test_mode
    # remove_columns :users,  :test_mode
  end
end
