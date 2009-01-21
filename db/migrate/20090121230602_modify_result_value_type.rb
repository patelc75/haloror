class ModifyResultValueType < ActiveRecord::Migration
  def self.up
    remove_column :atp_item_results, :result_value
    add_column :atp_item_results, :result_value, :string, :limit => 1024
  end

  def self.down
    remove_column :atp_item_results, :result_value
    add_column :atp_item_results, :result_value, :boolean
  end
end
