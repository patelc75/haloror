class AddGroupIdToSystemTimeouts < ActiveRecord::Migration
  def self.up
    add_column :system_timeouts, :group_id, :integer
    #
    # safely migrate existing data
    SystemTimeout::DEFAULTS.keys.each do |kind|
      found = SystemTimeout.find_or_create_by_mode( DEFAULTS[ kind] )
      found.update_attributes( DEFAULTS[kind] ) unless found.blank?
    end
  end

  def self.down
    remove_column :system_timeouts, :group_id
  end
end
