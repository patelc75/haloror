class UserIntakeSubmitLegalFields < ActiveRecord::Migration
  def self.up
    remove_column :user_intakes, :locked
    add_column :user_intakes, :submitted_at, :datetime
    add_column :user_intakes, :legal_agreement_at, :datetime
    add_column :user_intakes, :paper_copy_at, :datetime
  end

  def self.down
    remove_columns :user_intakes, :submitted_at, :legal_agreement_at, :paper_copy_at
    add_column :user_intakes, :locked, :boolean
  end
end
