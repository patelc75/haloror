# 
#  Wed Dec 22 22:28:04 IST 2010, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/3901
class RemoveObsoleteColumnsFromDialUpStatuses < ActiveRecord::Migration
  def self.up
    #   * stores "prim" "alt"
    #   * "global" "local" stored in dialup_type
    add_column     :dial_up_statuses, :dialup_rank,           :string

    #   * these are obsolete columns. can be removed
    remove_columns :dial_up_statuses, :alt_username,          :alt_password
    remove_columns :dial_up_statuses, :global_alt_username,   :global_alt_password
    remove_columns :dial_up_statuses, :global_prim_username,  :global_prim_password
  end

  def self.down
    # no need to get these fields back
  end
end
