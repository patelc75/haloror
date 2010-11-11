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
      (1..3).each {|e| @user_intake.send("no_caregiver_#{e}=", false) }
      # @user_intake.no_caregiver_1 = false
      # @user_intake.no_caregiver_2 = false
      # @user_intake.no_caregiver_3 = false
      @attributes = Factory.build( :user).attributes.merge( "profile_attributes" => Factory.build( :profile).attributes )
    end

    # check each user type in memory
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|

      specify { @user_intake.send("#{user_type}".to_sym).should be_valid }
      specify { @user_intake.send("#{user_type}".to_sym).profile.should be_valid }

      it "should allow assigning attributes to #{user_type}" do
        @user_intake.send( "#{user_type}_attributes=".to_sym, @attributes)
        @user_intake.send("#{user_type}".to_sym).email.should == @attributes["email"]
        @user_intake.send("#{user_type}".to_sym).profile.first_name.should == @attributes["profile_attributes"]["first_name"]
      end
    end
    
  end

  #  
  #  Thu Nov  4 05:37:58 IST 2010, ramonrails 
  #   Defines the behavior of assigning and fetching role_options for each caregiver
  context "roles_users_options" do
    context "in memory - object" do
      before(:each) do
        @user_intake = Factory.build( :user_intake)
        #  same as: 
        #   @cg1_options = Factory.build( :roles_users_option, { :position => 1, :text_active => true })
        #   @cg2_options = Factory.build( :roles_users_option, { :position => 2, :text_active => true })
        #   @cg3_options = Factory.build( :roles_users_option, { :position => 3, :text_active => true })         
        (1..3).each {|_index| instance_variable_set("@cg#{_index}_options", Factory.build( :roles_users_option, { :position => _index, :text_active => true })) }
        #  same as:
        #   @user_intake.caregiver1_role_options = @cg1_options
        #   @user_intake.caregiver2_role_options = @cg2_options
        #   @user_intake.caregiver3_role_options = @cg3_options
        (1..3).each {|_index| @user_intake.send("caregiver#{_index}_role_options=", instance_variable_get("@cg#{_index}_options")) }
      end
      
      #  same as:
      #   @user_intake.caregiver1_role_options.should == @cg1_options
      #   @user_intake.caregiver2_role_options.should == @cg2_options
      #   @user_intake.caregiver3_role_options.should == @cg3_options
      (1..3).each do |_index|
        specify { @user_intake.send("caregiver#{_index}_role_options").attributes.should == instance_variable_get("@cg#{_index}_options").attributes }
      end
    end

    context "in memory - attributes" do
      before(:each) do
        @user_intake = Factory.build( :user_intake)
        #  same as: 
        #   @cg1_options = Factory.build( :roles_users_option, { :position => 1, :text_active => true }).attributes
        #   @cg2_options = Factory.build( :roles_users_option, { :position => 2, :text_active => true }).attributes
        #   @cg3_options = Factory.build( :roles_users_option, { :position => 3, :text_active => true }).attributes
        (1..3).each {|_index| instance_variable_set("@cg#{_index}_options", Factory.build( :roles_users_option, { :position => _index, :text_active => true }).attributes) }
        #  same as:
        #   @user_intake.caregiver1_role_options = @cg1_options
        #   @user_intake.caregiver2_role_options = @cg2_options
        #    @user_intake.caregiver3_role_options = @cg3_options
        (1..3).each {|_index| @user_intake.send("caregiver#{_index}_role_options=", instance_variable_get("@cg#{_index}_options")) }
      end
      
      #  same as:
      #   @user_intake.caregiver1_role_options.attributes.should == @cg1_options
      #   @user_intake.caregiver2_role_options.attributes.should == @cg2_options
      #   @user_intake.caregiver3_role_options.attributes.should == @cg3_options
      (1..3).each do |_index|
        specify { @user_intake.send("caregiver#{_index}_role_options").attributes.should == instance_variable_get("@cg#{_index}_options") }
      end
    end

    context "saved - object" do
      before(:each) do
        user_intake = Factory.create( :user_intake)
        #  same as: 
        #   @cg1_options = Factory.build( :roles_users_option, { :position => 1, :text_active => true })
        #   @cg2_options = Factory.build( :roles_users_option, { :position => 2, :text_active => true })
        #   @cg3_options = Factory.build( :roles_users_option, { :position => 3, :text_active => true })         
        (1..3).each {|_index| instance_variable_set("@cg#{_index}_options", Factory.build( :roles_users_option, { :position => _index, :text_active => true })) }
        #  same as:
        #   @user_intake.caregiver1_role_options = @cg1_options
        #   @user_intake.caregiver2_role_options = @cg2_options
        #   @user_intake.caregiver3_role_options = @cg3_options
        (1..3).each do |_index|
          user_intake.send("caregiver#{_index}_role_options=", instance_variable_get("@cg#{_index}_options"))
        end
        user_intake.save
        @user_intake = UserIntake.find( user_intake.id)
      end
      
      #  same as:
      #   @user_intake.caregiver1_role_options.should == @cg1_options
      #   @user_intake.caregiver2_role_options.should == @cg2_options
      #   @user_intake.caregiver3_role_options.should == @cg3_options
      (1..1).each do |_index|
        specify { @user_intake.send("caregiver#{_index}_role_options").should == instance_variable_get("@cg#{_index}_options") }
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
        ui.save.should be_true
        @ui = UserIntake.find( ui.id) # load form database
      end
      specify { @ui.senior.should be_valid } # valid senior
      specify { @ui.senior.profile.should be_valid } # valid senior profile
      specify { @ui.subscriber.should be_valid } # valid subscriber
      specify { @ui.subscriber.profile.should be_valid } # valid subscriber profile
      specify { @ui.group.should be_valid } # valid group
      specify { @ui.subscriber.should_not == @ui.senior }
      specify { @ui.subscriber.profile.should_not == @ui.senior.profile } # both profiles are different
      specify { lambda { @ui.senior.is_halouser_of?( @ui.group) }.should be_true } # valid halouser role
      specify { lambda { @ui.subscriber.is_subscriber_of?( @ui.senior) }.should be_true } # subscriber role
      #
      # Wed Oct 27 23:15:10 IST 2010
      #   * we will tackle this after 1.6.0 release. we might shift to FK approach and skip this fix
      # specify { lambda { @ui.subscriber.is_halouser_of?( @ui.group) }.should be_false } # subscriber is not halouser
    end

    context "subscriber is not senior, subscriber is caregiver" do
      before(:all) do
        ui = Factory.build( :user_intake) # build associations
        ui.subscriber_is_user = false # subcriber different from senior
        ui.subscriber_is_caregiver = true # subscriber is caregiver1
        ui.save.should be_true
        @ui = UserIntake.find( ui.id) # load form database
      end
      specify { @ui.senior.should be_valid } # senior
      specify { @ui.senior.profile.should be_valid }
      specify { @ui.subscriber.should be_valid } # subscriber
      specify { @ui.subscriber.profile.should be_valid }
      specify { @ui.caregiver1.should be_valid } # caregiver1
      specify { @ui.caregiver1.profile.should be_valid }
      specify { @ui.group.should be_valid } # group
      specify { @ui.subscriber.should_not == @ui.senior }
      specify { @ui.caregiver1.should == @ui.subscriber }
      specify { @ui.subscriber.profile.should_not == @ui.senior.profile } # both profiles are different
      specify { lambda { @ui.senior.is_halouser_of?( @ui.group) }.should be_true } # valid halouser role
      specify { lambda { @ui.subscriber.is_subscriber_of?( @ui.senior) }.should be_true } # subscriber role
      specify { lambda { @ui.caregiver1.is_caregiver_of?( @ui.senior) }.should be_true } # caregiver role
    end

    # Wed Oct 27 23:59:00 IST 2010
    #   A major bug about caregiver positions was identified by this test
    #   Keep this test available to ensure appropriate user_intake behavior
    context "all caregivers defined" do
      before(:all) do
        ui = Factory.build( :user_intake) # build associations
        ui.subscriber_is_user = false
        ui.subscriber_is_caregiver = false
        # we already have caregivers defined. just switch off the flag
        (1..3).each {|e| ui.send("no_caregiver_#{e}=", false) } # no_caregiver_? switched off
        ui.save.should be_true
        @ui = UserIntake.find( ui.id) # load form database
      end
      specify { @ui.senior.should be_valid } # senior
      specify { @ui.senior.profile.should be_valid }
      specify { @ui.subscriber.should be_valid } # subscriber
      specify { @ui.subscriber.profile.should be_valid }
      specify { @ui.caregiver1.should be_valid } # caregiver1
      specify { @ui.caregiver1.profile.should be_valid }
      specify { @ui.group.should be_valid } # group
      specify { @ui.subscriber.should_not == @ui.senior }
      specify { @ui.caregiver1.should_not == @ui.subscriber }
      specify { @ui.caregiver1.should be_valid }
      specify { @ui.caregiver2.should be_valid }
      specify { @ui.caregiver3.should be_valid }
      specify { @ui.subscriber.profile.should_not == @ui.senior.profile } # both profiles are different
      specify { lambda { @ui.senior.is_halouser_of?( @ui.group) }.should be_true } # valid halouser role
      specify { lambda { @ui.subscriber.is_subscriber_of?( @ui.senior) }.should be_true } # subscriber role
      specify { lambda { @ui.caregiver1.is_caregiver_of?( @ui.senior) }.should be_true } # caregiver role
      specify { lambda { @ui.caregiver2.is_caregiver_of?( @ui.senior) }.should be_true }
      specify { lambda { @ui.caregiver3.is_caregiver_of?( @ui.senior) }.should be_true }
    end
  end # create user intake

  context "editing an existing user intake - senior = subscriber" do
    before(:all) do
      ui = Factory.build( :user_intake) # build associations
      ui.subscriber_is_user = false
      ui.subscriber_is_caregiver = false
      # we already have caregivers defined. just switch off the flag
      (1..3).each {|e| ui.send("no_caregiver_#{e}=", false) } # no_caregiver_? switched off
      ui.senior_attributes = Factory.build( :user).attributes.merge( "profile_attributes" => Factory.build(:profile).attributes)
      ui.save.should be_true
      @ui = UserIntake.find( ui.id) # load form database
    end
    specify { @ui.senior.should be_valid } # senior
    specify { @ui.senior.profile.should be_valid }
    specify { @ui.subscriber.should be_valid } # subscriber
    specify { @ui.subscriber.profile.should be_valid }
    specify { @ui.subscriber.should == @ui.senior }
    specify { @ui.subscriber.profile.should == @ui.senior.profile } # both profiles are different
    specify { lambda { @ui.senior.is_halouser_of?( @ui.group) }.should be_true } # valid halouser role
    specify { lambda { @ui.subscriber.is_subscriber_of?( @ui.senior) }.should be_true } # subscriber role
  end # editing
end #user intake
