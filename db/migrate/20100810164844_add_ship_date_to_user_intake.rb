class AddShipDateToUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :shipped_at, :datetime
  end

  def self.down
    remove_columns :user_intakes, :shipped_at
  end
end
