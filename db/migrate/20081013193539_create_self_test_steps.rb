class CreateSelfTestSteps < ActiveRecord::Migration
  def self.up
    create_table :self_test_steps do |t|
      t.column :id, :primary_key, :null => false 
      t.column :timestamp, :timestamp_with_time_zone
      t.column :user_id, :integer
      t.column :halo_user_id, :integer
      t.column :self_test_step_description_id, :integer
    end
    create_table :self_test_step_descriptions do |t|
      t.column :id, :primary_key, :null => false
      t.column :description, :string
    end
  end

  def self.down
    drop_table :self_test_step_description
    drop_table :self_test_steps
  end
end
