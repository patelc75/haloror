class AddDialUpColumnsToUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :local_primary, :string
    add_column :user_intakes, :local_secondary, :string
    add_column :user_intakes, :global_primary, :string
    add_column :user_intakes, :global_secondary, :string
  end

  def self.down
    remove_columns :user_intakes, :local_primary, :local_secondary, :global_primary, :global_secondary
  end
end
