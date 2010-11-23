class UsersActivationSentAt < ActiveRecord::Migration
  def self.up
    add_column :users, :activation_sent_at, :datetime
  end

  def self.down
    remove_column :users, :activation_sent_at
  end
end
