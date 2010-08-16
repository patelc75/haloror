class AddColumnsToRmas < ActiveRecord::Migration
  def self.up
    add_column :rmas, :termination_requested_on,  :date
    add_column :rmas, :discontinue_bill_on,       :date
    add_column :rmas, :discontinue_service_on,    :date
    add_column :rmas, :received_verified_on,      :date
  end

  def self.down
    remove_columns :rmas, :termination_requested_on, :discontinue_bill_on
    remove_columns :rmas, :discontinue_service_on, :received_verified_on
  end
end
