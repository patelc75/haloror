class AddInstalledAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :installed_at, :datetime
  end

  def self.down
    remove_column :users, :installed_at
  end
end
