class LockUserIntakeOnSubmit < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :locked, :boolean, :default => false
  end

  def self.down
    remove_column :user_intakes, :locked
  end
end
