class RoleOptionsInUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :caregiver1_email, :boolean
    add_column :user_intakes, :caregiver1_text, :boolean
    add_column :user_intakes, :caregiver2_email, :boolean
    add_column :user_intakes, :caregiver2_text, :boolean
    add_column :user_intakes, :caregiver3_email, :boolean
    add_column :user_intakes, :caregiver3_text, :boolean
  end

  def self.down
    remove_columns :user_intakes, :caregiver1_email, :caregiver1_text
    remove_columns :user_intakes, :caregiver2_email, :caregiver2_text
    remove_columns :user_intakes, :caregiver3_email, :caregiver3_text
  end
end
