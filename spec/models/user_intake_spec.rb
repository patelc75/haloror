require "spec_helper"
require "factory_girl"

describe UserIntake do
  ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user|
    it "should have a #{user}" do
      UserIntake.new.send("#{user}".to_sym).should_not be_blank
    end

    it "should allow assigning attributes to #{user}" do
      user_intake = UserIntake.new
      user_intake.send("#{user}=".to_sym, User.new(:email => "test@senior.com").attributes)
      user_intake.send("#{user}").email.should == "test@senior.com"
    end

    it "should have profile for #{user}" do
      UserIntake.new.send("#{user}".to_sym).profile.should_not be_blank
    end
    
    it "should have halouser role for senior" do
      user_intake = UserIntake.new(:subscriber_is_user => true)
      user_intake.senior = User.new(:email => "senior@example.com")
      user_intake.save
      user_intake.senior.is_halouser?.should be_true
    end
    
    # it "should have subscriber role for senior when subscriber_is_user" do
    #   user_intake = Factory.create(:user_intake, :subscriber_is_user => true)
    #   user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true
    # end
    # 
    # it "should have caregiver role for subscriber when subscriber_is_caregiver" do
    #   user_intake = Factory.create(:user_intake, :subscriber_is_caregiver => true)
    #   user_intake.subscriber.is_caregiver_of?(user_intake.senior).should be_true
    # end
    # 
    # it "should have a role_options for caregiver when subscriber_is_caregiver" do
    #   user_intake = Factory.create(:user_intake, :subscriber_is_caregiver => true)
    #   user_intake.subscriber.role_options_for_senior(user_intake.senior).should_not be_blank
    # end
    # 
    # it "should have a role_options for caregiver when caregiver1 is other than subscriber" do
    #   user_intake = Factory.create(:user_intake, :subscriber_is_caregiver => false)
    #   user_intake.caregiver1.role_options_for_senior(user_intake.senior).should_not be_blank
    # end
  end
end