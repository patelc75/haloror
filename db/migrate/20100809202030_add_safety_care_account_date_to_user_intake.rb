class AddSafetyCareAccountDateToUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :sc_account_created_on, :date
  end

  def self.down
    remove_column :user_intakes, :sc_account_created_on
  end
end
