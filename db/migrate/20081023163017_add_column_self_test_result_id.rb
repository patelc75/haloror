class AddColumnSelfTestResultId < ActiveRecord::Migration
  def self.up
    add_column :self_test_item_results, :self_test_result_id, :integer
  end

  def self.down
    remove_column :self_test_item_results, :self_test_result_id
  end
end
