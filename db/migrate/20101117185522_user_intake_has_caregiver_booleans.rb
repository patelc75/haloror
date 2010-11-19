class UserIntakeHasCaregiverBooleans < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :no_caregiver_1, :boolean
    add_column :user_intakes, :no_caregiver_2, :boolean
    add_column :user_intakes, :no_caregiver_3, :boolean
  end

  def self.down
    remove_columns :user_intakes, :no_caregiver_1, :no_caregiver_2, :no_caregiver_3
  end
end
