class DropAtpItemsDeviceTypesCreateAtpItemsDeviceRevisions < ActiveRecord::Migration
  def self.up
    drop_table :atp_items_device_types
    create_table :atp_items_device_revisions, :force => true do |t|
      t.column :id, :primary, :null => false
      t.column :atp_item_id, :integer, :null => false
      t.column :device_revision_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :atp_items_device_revisions
    create_table :atp_items_device_types, :force => true do |t|
      t.column :id, :primary, :null => false
      t.column :atp_item_id, :integer, :null => false
      t.column :device_type_id, :integer, :null
    end
  end
end
