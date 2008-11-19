class AddWorkorderIdToDevice < ActiveRecord::Migration
  def self.up
    add_column :devices, :work_order_id, :integer
  end

  def self.down
  end
end
