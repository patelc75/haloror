class AddColumnQuestionKeyAndAnswer < ActiveRecord::Migration
  def self.up
    add_column :call_center_steps, :question_key, :string
    add_column :call_center_steps, :notes, :text
    remove_column :call_center_steps, :answer
    add_column :call_center_steps, :answer, :boolean
  end

  def self.down
    remove_column :call_center_steps, :question_key
    remove_column :call_center_steps, :notes, :text
    remove_column :call_center_steps, :answer
    add_column :call_center_steps, :answer, :text
  end
end
