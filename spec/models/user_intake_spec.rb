require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserIntake do

  # ========================
  # = in-memory test cases =
  # ========================

  context "In memory records" do
    before(:all) do
      @user_intake = Factory.build( :user_intake)
      @user_intake.skip_validation = true # just save user_intake + associations
      @user_intake.subscriber_is_user = false
      @user_intake.subscriber_is_caregiver = false
      @user_intake.no_caregiver_1 = false
      @user_intake.no_caregiver_2 = false
      @user_intake.no_caregiver_3 = false
      @attributes = Factory.build( :user).attributes.merge( :profile_attributes => Factory.build( :profile).attributes )
    end

    # check each user type in memory
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|

      specify { @user_intake.send("#{user_type}".to_sym).should be_valid }
      specify { @user_intake.send("#{user_type}".to_sym).profile.should be_valid }

      it "should allow assigning attributes to #{user_type}" do
        @user_intake.send(  "#{user_type}_attributes=".to_sym, @attributes)
        @user_intake.send("#{user_type}".to_sym).email.should == @attributes[:email]
        @user_intake.send("#{user_type}".to_sym).profile.first_name.should == @attributes[:profile_attributes][:first_name]
      end
    end
  end

  # =================
  # = saved records =
  # =================

  context "create user intake" do
    context "subscriber is senior" do
      before(:all) do
        ui = Factory.build( :user_intake) # build associations
        ui.subscriber_is_user = true # keep subscriber same as senior
        ui.save
        @ui = UserIntake.find( ui.id) # load form database
      end
      specify { @ui.senior.should be_valid } # valid senior
      specify { @ui.senior.profile.should be_valid } # valid senior profile
      specify { @ui.subscriber.should be_valid } # valid subscriber
      specify { @ui.subscriber.profile.should be_valid } # valid subscriber profile
      specify { @ui.group.should be_valid } # valid group
      specify { @ui.subscriber.should == @ui.senior } # senior and subscriber should be same
      specify { lambda { @ui.senior.is_halouser_of?( @ui.group) }.should be_true } # valid halouser role
      specify { lambda { @ui.subscriber.is_subscriber_of?( @ui.senior) }.should be_true } # subscriber role
    end

    context "subscriber is not senior" do
      before(:all) do
        ui = Factory.build( :user_intake) # build associations
        ui.subscriber_is_user = false # subcriber different from senior
        _subscriber_attributes = Factory.build( :user, :email => "subscriber@test.com").attributes
        _subscriber_attributes.merge( :profile_attributes => Factory.build(:profile).attributes )
        ui.subscriber_attributes = _subscriber_attributes
        ui.save
        @ui = UserIntake.find( ui.id) # load form database
      end
      specify { @ui.senior.should be_valid } # valid senior
      specify { @ui.senior.profile.should be_valid } # valid senior profile
      specify { @ui.subscriber.should be_valid } # valid subscriber
      specify { @ui.subscriber.profile.should be_valid } # valid subscriber profile
      specify { @ui.group.should be_valid } # valid group
      specify { @ui.subscriber.should_not == @ui.senior } # senior and subscriber should be same
      specify { @ui.subscriber.profile.should_not == @ui.senior.profile } # both profiles are different
      specify { lambda { @ui.senior.is_halouser_of?( @ui.group) }.should be_true } # valid halouser role
      specify { lambda { @ui.subscriber.is_subscriber_of?( @ui.senior) }.should be_true } # subscriber role
    end

    context "subscriber is not senior, subscriber is caregiver" do
    end

    context "all caregivers defined" do
    end
  end # create user intake

  context "editing an existing user intake" do
    # before(:each) { Factory.create( :user_intake) }
  end # editing
end #user intake
