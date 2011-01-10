class DropColumnsFromUserIntake < ActiveRecord::Migration
  def self.up
    remove_columns :user_intakes, :local_primary, :local_secondary, :global_primary, :global_secondary
  end

  def self.down
  end
end
