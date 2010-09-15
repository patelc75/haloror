class AddLoginColumnsToDialUpStatuses < ActiveRecord::Migration
  def self.up
    add_column :dial_up_statuses, :username,              :string
    add_column :dial_up_statuses, :password,              :string
    add_column :dial_up_statuses, :alt_username,          :string
    add_column :dial_up_statuses, :alt_password,          :string
    add_column :dial_up_statuses, :global_alt_username,   :string
    add_column :dial_up_statuses, :global_alt_password,   :string
    add_column :dial_up_statuses, :global_prim_username,  :string
    add_column :dial_up_statuses, :global_prim_password,  :string
  end

  def self.down
    remove_columns :dial_up_statuses, :username, :password
    remove_columns :dial_up_statuses, :alt_username, :alt_password
    remove_columns :dial_up_statuses, :global_alt_username, :global_alt_password
    remove_columns :dial_up_statuses, :global_prim_username, :global_prim_password
  end
end
