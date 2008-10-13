class CreateSelfTestResults < ActiveRecord::Migration
  def self.up
    create_table :self_test_results do |t|
      t.column :id,         :primary_key,               :null => false
      t.column :result,     :boolean,                   :null => false
      t.column :cmd_type,   :string,                    :null => false
      t.column :device_id,  :integer,                   :null => false
      t.column :timestamp,  :timestamp_with_time_zone,  :null => false
    end
    
    create_table :self_test_item_results do |t|
      t.column :id,           :primary_key,               :null => false
      t.column :description,  :string
      t.column :result,       :boolean
      t.column :result_value, :string
      t.column :device_id,    :integer
      t.column :operator_id,  :integer
      t.column :timestamp,    :timestamp_with_time_zone,  :null => false
    end
  end

  def self.down
    drop_table :self_test_results
  end
end
