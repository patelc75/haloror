class AddFieldsToHaloDbgMsgs < ActiveRecord::Migration
  def self.up
    add_column :halo_debug_msgs, :source_device_type, :string
    add_column :halo_debug_msgs, :device_id, :integer
    add_column :halo_debug_msgs, :dbg_level, :string
	add_column :halo_debug_msgs, :description, :text
  end

  def self.down
    remove_column :halo_debug_msgs, :source_device_type
    remove_column :halo_debug_msgs, :device_id
    remove_column :halo_debug_msgs, :dbg_level
    remove_column :halo_debug_msgs, :description
  end
end