class AddStatusFieldToUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :status, :string
  end

  def self.down
    remove_column :user_intakes, :status
  end
end
