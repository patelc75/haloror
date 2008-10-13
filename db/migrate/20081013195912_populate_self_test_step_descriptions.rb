class PopulateSelfTestStepDescriptions < ActiveRecord::Migration
  def self.up
    SelfTestStepDescription.create(:id => 1, :description => "Registered")
    SelfTestStepDescription.create(:id => 2, :description => "Self Test Gateway Complete")
    SelfTestStepDescription.create(:id => 3, :description => "Self Test Chest Strap Complete")
    SelfTestStepDescription.create(:id => 4, :description => "System OK")
  end

  def self.down
  end
end
