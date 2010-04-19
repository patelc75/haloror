require "spec_helper"
require "factory_girl"

describe UserIntake do
  
  # in memory records
  context "In memory records" do
    before(:each) do
      @user_intake = UserIntake.new
    end
    #
    # check each user type in memory
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|

      it "should have a #{user_type}" do
        user = @user_intake.send("#{user_type}".to_sym)
        user.should_not be_blank
      end

      it "should allow assigning attributes to #{user_type}" do
        user = @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@example.com").attributes)
        user.email.should == "#{user_type}@example.com"
      end

      it "should have profile for #{user_type}" do
        @user_intake.send("#{user_type}".to_sym).profile.should_not be_blank
      end
    end
  end
    
  # saved records
  context "saved records" do
    before(:each) do
      @user_intake = UserIntake.new
    end

    #
    # check each user type after save
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|

      it "should have a #{user_type}" do
        user = @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@test.com"))
        @user_intake.save
        @user_intake.reload
        user = @user_intake.send("#{user_type}".to_sym)
        user.should_not be_blank
        user.email.should == "#{user_type}@test.com"
      end

      it "should have profile for #{user_type}" do
        @user_intake.send("#{user_type}".to_sym).profile.should_not be_blank
      end
    end
  end
    
    # it "should have halouser role for senior" do
    #   @user_intake.subscriber_is_user = true
    #   @user_intake.senior = User.new(:email => "senior@example.com")
    #   user_intake.save
    #   user_intake.senior.is_halouser?.should be_true
    # end
    # 
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
    
    # check senior, subscriber, ... attributes when saved, aborted on new_record?, exists?
end
