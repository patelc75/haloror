class AddPaperCopySubmittedOnToUserIntake < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :paper_copy_submitted_on, :date
  end

  def self.down
    remove_column :user_intakes, :paper_copy_submitted_on
  end
end
