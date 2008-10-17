class PopulateSelfTestStepDescriptionSerialNumbers < ActiveRecord::Migration
  def self.up
    SelfTestStepDescription.create(:description => "Installation Serial Numbers Entered")
    SelfTestStepDescription.create(:description => "Installation Serial Numbers Failed")
  end

  def self.down
  end
end
