class RepopulateSelfTestStepDescriptions < ActiveRecord::Migration
  def self.up
    descriptions = SelfTestStepDescription.find(:all)
    SelfTestStepDescription.delete(descriptions)
    SelfTestStepDescription.new(:id => 1, :description => "Registered").save!
    SelfTestStepDescription.new(:id => 2, :description => "Self Test Gateway Complete").save!
    SelfTestStepDescription.new(:id => 3, :description => "Self Test Chest Strap Complete").save!
    SelfTestStepDescription.new(:id => 4, :description => "Self Test Phone Complete").save!
    SelfTestStepDescription.new(:id => 5, :description => "Chest Strap Fastened Detected").save!
    SelfTestStepDescription.new(:id => 6, :description => "Heartrate Detected").save!
  end

  def self.down
    descriptions = SelfTestStepDescription.find(:all)
    SelfTestStepDescription.delete(descriptions)    
  end
end
