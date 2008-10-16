class RepopulateTestStepDescriptionsIds < ActiveRecord::Migration
  def self.up
    drop_table :self_test_step_descriptions
    
    create_table :self_test_step_descriptions do |t|
      t.column :id, :primary_key, :null => false
      t.column :description, :string
    end
    
    SelfTestStepDescription.create(:description => "Installation Session Created")
    SelfTestStepDescription.create(:description => "Registration Complete")
    SelfTestStepDescription.create(:description => "Registration Failed")
    SelfTestStepDescription.create(:description => "Self Test Chest Strap Mgmt Command Created")
    SelfTestStepDescription.create(:description => "Self Test Phone Mgmt Command Created")
    SelfTestStepDescription.create(:description => "Self Test Gateway Complete")
    SelfTestStepDescription.create(:description => "Self Test Gateway Failed")
    SelfTestStepDescription.create(:description => "Self Test Gateway Timeout")
    SelfTestStepDescription.create(:description => "Self Test Chest Strap Complete")
    SelfTestStepDescription.create(:description => "Self Test Chest Strap Failed")
    SelfTestStepDescription.create(:description => "Self Test Chest Strap Timeout")
    SelfTestStepDescription.create(:description => "Self Test Phone Complete")
    SelfTestStepDescription.create(:description => "Self Test Phone Failed")
    SelfTestStepDescription.create(:description => "Self Test Phone Timeout")
    SelfTestStepDescription.create(:description => "User Prompted to Wear Chest Strap")
    SelfTestStepDescription.create(:description => "Chest Strap Fastened Detected")
    SelfTestStepDescription.create(:description => "Chest Strap Fastened Detection Timeout")
    SelfTestStepDescription.create(:description => "Heartrate Detected")
    SelfTestStepDescription.create(:description => "Heartrate Detection Timeout")
    SelfTestStepDescription.create(:description => "User Prompted to Start Range Test")
    SelfTestStepDescription.create(:description => "User Prompted to Stop Range Test")
    SelfTestStepDescription.create(:description => "Range Test Complete")
    SelfTestStepDescription.create(:description => "Range Test Failure")
    SelfTestStepDescription.create(:description => "Slow Poling Mgmt Command Created")
    SelfTestStepDescription.create(:description => "User Prompted to Add Range Test Notes")
    SelfTestStepDescription.create(:description => "Installation Session Complete")
  end

  def self.down
  end
end
