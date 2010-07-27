class UpdateUserIntakeInstallationDateToDatetime < ActiveRecord::Migration
  def self.up
    remove_column :user_intakes, :installation_date
    add_column :user_intakes, :installation_datetime, :datetime
  end

  def self.down
    remove_column :user_intakes, :installation_datetime
    add_column :user_intakes, :installation_date, :datetime
  end
end
