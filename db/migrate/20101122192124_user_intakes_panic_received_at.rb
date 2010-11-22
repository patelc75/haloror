class UserIntakesPanicReceivedAt < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :panic_received_at, :datetime
  end

  def self.down
    remove_column :user_intakes, :panic_received_at
  end
end
