class CreateCallCenterSteps < ActiveRecord::Migration
  def self.up
    create_table :call_center_steps do |t|
      t.column :id, :primary_key, :null => false
      t.column :type, :string
      t.column :text, :text
      t.column :answer, :text
      t.column :next_step_id, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :call_center_steps
  end
end
