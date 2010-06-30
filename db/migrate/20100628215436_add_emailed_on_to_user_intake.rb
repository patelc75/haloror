class AddEmailedOnToUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :emailed_on, :date
  end

  def self.down
    remove_column :user_intakes, :emailed_on
  end
end
