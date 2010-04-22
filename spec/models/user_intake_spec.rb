require File.join(File.dirname(__FILE__), "..", "spec_helper")
require "factory_girl"

describe UserIntake do
  
  # common methods
  
  def profile_hash(user_type)
    {
      :first_name => "#{user_type} first name",
      :last_name => "#{user_type} last name",
      :address => "#{user_type} address",
      :city => "#{user_type} city", 
      :state => "#{user_type} state", 
      :zipcode => ("%05d" % rand(99999)), 
      :time_zone => ("%05d" % rand(99999)), 
      :home_phone => ("%10d" % rand(99999_99999)), 
      :cell_phone => ("%10d" % rand(99999_99999)), 
      :account_number => ("%04d" % rand(9999)), 
      :hospital_number => ("%10d" % rand(99999_99999)), 
      :doctor_phone => ("%10d" % rand(99999_99999)), 
      :carrier_id => Carrier.create(:name => "#{user_type} carrier").id, 
      :emergency_number_id => EmergencyNumber.create(:name => ("%10d" % rand(99999_99999))).id,
      :medications => "#{user_type} medications"
    }
  end

  def add_senior
    @user_intake.senior = User.new(:email => "senior@example.com")
    @user_intake.senior.profile = Profile.new(profile_hash("senior"))
  end

  def add_subscriber
    @user_intake.subscriber = User.new(:email => "subscriber@example.com")
    @user_intake.subscriber.profile = Profile.new(profile_hash("subscriber"))
  end

  def add_caregivers
    (1..3).each do |index| # assign caregivers
      @user_intake.send("no_caregiver_#{index}=".to_sym, false)
      @user_intake.send("caregiver#{index}=".to_sym, User.new(:email => "caregiver#{index}@example.com"))
      caregiver = @user_intake.send("caregiver#{index}".to_sym)
      caregiver.send("profile=", Profile.new(profile_hash("caregiver#{index}")))
    end
  end
  
  # callback events
  
  before(:each) do
    @user_intake = UserIntake.new
    @user_intake.group = Group.create(:name => "group")
  end
  
  # in memory records
  
  context "In memory records" do
    #
    # check each user type in memory
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|

      it "should have a #{user_type}" do
        user = @user_intake.send("#{user_type}".to_sym)
        user.should_not be_blank
      end

      it "should allow assigning attributes to #{user_type}" do
        @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@example.com").attributes)
        user = @user_intake.send("#{user_type}".to_sym)
        user.email.should == "#{user_type}@example.com"
      end

      it "should have profile for #{user_type}" do
        @user_intake.send("#{user_type}".to_sym).profile.should_not be_blank
      end
    end
  end
    
  # saved records
  
  context "saved records" do
    #
    # check each user type after save
    context "associations" do
      ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|
        it "should save the associations correctly" do
          @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@test.com"))
          @user_intake.save

          @user_intake.new_record?.should be_false
          @user_intake.send("#{user_type}".to_sym).new_record?.should be_false
          @user_intake.users.length.should be(1)
          @user_intake.users.first.should == @user_intake.send("#{user_type}".to_sym)
          user =  @user_intake.send("#{user_type}".to_sym)
          user.email.should == "#{user_type}@test.com"
          user.roles.should_not be_blank
          user.roles.each { |e| e.new_record?.should be_false }
        end

        it "should have a #{user_type}" do
          @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@test.com"))
          @user_intake.save

          (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
          user = user_intake.send("#{user_type}".to_sym)
          user.should_not be_blank
          user.email.should == "#{user_type}@test.com"
        end

        it "should save profile for #{user_type}" do
          user_hash = User.new(:email => "#{user_type}@test.com").attributes
          local_profile_hash = profile_hash(user_type)
          attributes = user_hash.merge( "profile_attributes" => Profile.new(local_profile_hash).attributes)
          @user_intake.send("#{user_type}=".to_sym, attributes)
          @user_intake.save

          (user_intake = UserIntake.find_by_id(@user_intake.id)).should_not be_blank
          (user = user_intake.send("#{user_type}".to_sym)).should_not be_blank
          profile = user.profile
          profile.should_not be_blank
          local_profile_hash.each {|k,v| profile.send("#{k}").should == v }
        end
      end # each
    end # associations
    
    context "roles" do
      before(:each) do
        @user_intake.subscriber_is_user = true
        @user_intake.senior = User.new(:email => "senior@example.com")
        @user_intake.save
      end
      
      it "should have halouser role for senior" do
        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.senior.is_halouser_of?(user_intake.group).should be_true
      end

      it "should consider senior also as subscriber when flagged so" do
        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.subscriber.is_halouser_of?(user_intake.group).should be_true
        user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true
      end
    end
    
    context "attributes for profiles" do
      before(:each) do
        add_senior # assign senior profile
      end
      
      it "should have subscriber attributes for senior & subscriber, when senior is subscriber" do
        # assign subscriber. canot be :before
        add_subscriber
        @user_intake.save

        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true
        user_intake.senior.email.should == "subscriber@example.com"
        [:id, :email].each do |attribute|
          user_intake.subscriber.send(attribute).should be(user_intake.senior.send(attribute))
        end
      end
      
      it "should have different attributes for senior and subscriber when they are not marked same" do
        @user_intake.subscriber_is_user = false
        add_subscriber
        @user_intake.save

        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true
        ["senior", "subscriber"].each do |user_type|
          user = user_intake.send("#{user_type}")
          user.email.should == "#{user_type}@example.com"
        end
        [:id, :email].each do |attribute|
          user_intake.subscriber.send(attribute).should_not be(user_intake.senior.send(attribute))
        end
      end

      it "should allow senior, subscriber and subscriber as caregiver" do
        @user_intake.subscriber_is_user = false
        @user_intake.subscriber_is_caregiver = true
        add_subscriber
        @user_intake.save
        
        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.subscriber.is_caregiver_to?(user_intake.senior).should be_true
        user_intake.caregiver1.email.should be(user_intake.subscriber.email)
      end
      
      # it "should have different profile for each user when all of them are given" do
      #   @user_intake.subscriber_is_user = false
      #   add_subscriber
      #   add_caregivers # all caregivers are given
      #   @user_intake.save
      #   (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
      #   # ... add check for each different profile
      # end
    end
    
    # it "should have caregiver role for subscriber when subscriber_is_caregiver" do
    #   @user_intake.subscriber_is_user = false
    #   @user_intake.senior = User.new(:email => "senior@example.com")
    #   @user_intake.subscriber = User.new(:email => "subscriber@example.com")
    #   @user_intake.save
    # 
    #   (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
    #   user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true
    # end
    
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
    
  end # saved records
end #user intake
