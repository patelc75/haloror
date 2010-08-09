class SwitchToUsingUserStatusColumn < ActiveRecord::Migration
  def self.up
    remove_column :user_intakes, :status
  end

  def self.down
    add_column :user_intakes, :status, :string
  end
end
