class RemovePaperCopyAtFromUserIntake < ActiveRecord::Migration
  def self.up
    # 
    #  Thu Feb 10 00:55:01 IST 2011, ramonrails
    #   * switch data from removed column to the other column
    #   * only if, used column is blank and removed has data
    UserIntake.all( :conditions => ["paper_copy_at IS NOT NULL AND paper_copy_submitted_on IS NULL"]).each do |_intake|
      _intake.paper_copy_submitted_on = _intake.paper_copy_at
      _intake.send( :update_without_callbacks)
    end
    #   * now remove the column
    remove_column :user_intakes, :paper_copy_at
  end

  def self.down
    # use paper_copy_submitted_on instead of this
    # add_column :user_intakes, :paper_copy_at, :datetime
  end
end
