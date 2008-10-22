class AddColumnNotesToSelfTestSteps < ActiveRecord::Migration
  def self.up
    add_column :self_test_steps, :notes, :string
  end

  def self.down
    remove_column :self_test_steps, :notes
  end
end
