class UserIntakesMoreFields < ActiveRecord::Migration
  def self.up
    change_table :user_intakes do |t|
      t.column :group_id, :integer
      t.column :subscriber_is_user, :boolean
      t.column :subscriber_is_caregiver, :boolean
    end
  end

  def self.down
    remove_column :user_intakes, :group_id
    remove_column :user_intakes, :subscriber_is_user
    remove_column :user_intakes, :subscriber_is_caregiver
  end
end
