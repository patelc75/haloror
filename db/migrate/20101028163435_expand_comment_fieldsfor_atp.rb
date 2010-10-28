class ExpandCommentFieldsforAtp < ActiveRecord::Migration
  def self.up
    change_table :atp_test_results do |t|
      t.change :comments, :text
    end
    change_table :atp_items do |t|
      t.change :comments, :text
    end
    change_table :atp_item_results do |t|
      t.change :comments, :text
    end          
  end

  def self.down
  end
end
