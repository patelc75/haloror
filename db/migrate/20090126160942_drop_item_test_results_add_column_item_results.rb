class DropItemTestResultsAddColumnItemResults < ActiveRecord::Migration
  def self.up
    drop_table :atp_item_results_atp_test_results
    add_column :atp_item_results, :atp_test_result_id, :integer
  end

  def self.down
    remove_column :atp_item_results, :atp_test_result_id
    create_table :atp_item_results_atp_test_results, :id => false, :force => true do |t|
       t.column :atp_item_result_id, :integer
       t.column :atp_test_result_id, :integer
       t.column :update_at, :timestamp_with_time_zone
       t.column :created_at, :timestamp_with_time_zone
       t.column :created_by, :integer
       t.column :comments, :string
     end
  end
end
