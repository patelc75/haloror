class UserHasStatusChangeDate < ActiveRecord::Migration
  def self.up
    add_column :users, :status_changed_at, :datetime
  end

  def self.down
    remove_column :users, :status_changed_at
  end
end
