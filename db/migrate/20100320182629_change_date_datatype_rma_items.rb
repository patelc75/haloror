class ChangeDateDatatypeRmaItems < ActiveRecord::Migration
  def self.up
  	change_column :rma_items, :shipped_on, :datetime
  	change_column :rma_items, :reinstalled_on, :datetime
  	change_column :rma_items, :completed_on, :datetime
  	change_column :rma_items, :received_on, :datetime
  	change_column :rma_items, :atp_on, :datetime
  	change_column :rma_items, :created_at, :timestamp
  	change_column :rma_items, :updated_at, :timestamp
  end

  def self.down
  end
end
