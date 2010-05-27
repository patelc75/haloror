require File.join(File.dirname(__FILE__), "..", "spec_helper")

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

  def build_user(type)
    user = User.new( :email => "#{type}@example.com" )
    user.profile = Profile.new(profile_hash("#{type}"))
    user
  end
  
  def add_senior
    @user_intake.senior = build_user("senior")
  end

  def add_subscriber
    @user_intake.subscriber = build_user("subscriber")
  end

  def add_caregivers
    (1..3).each do |index| # assign caregivers
      @user_intake.send("no_caregiver_#{index}=".to_sym, false)
      @user_intake.send("caregiver#{index}=".to_sym, build_user("caregiver#{index}"))
      @user_intake.send("mem_caregiver#{index}_options=".to_sym, {:position => index})
    end
  end
  
  # in memory records
  
  context "In memory records" do
    before(:each) do
      @user_intake = UserIntake.new
      @user_intake.skip_validation = true # just save user_intake + associations
      @user_intake.subscriber_is_user = false
      @user_intake.subscriber_is_caregiver = false
      @user_intake.no_caregiver_1 = false
      @user_intake.no_caregiver_2 = false
      @user_intake.no_caregiver_3 = false
    end

    # check each user type in memory
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|

      it "should have a #{user_type}" do
        user = @user_intake.send("#{user_type}".to_sym)
        user.should_not be_blank
      end

      it "should have profile for #{user_type}" do
        @user_intake.send("#{user_type}".to_sym).profile.should_not be_blank
      end

      it "should allow assigning attributes to #{user_type}" do
        @user_intake.send(  "#{user_type}=".to_sym, 
          User.new( 
            :email => "#{user_type}@example.com",
            :profile_attributes => profile_hash(user_type)
          )
        )
        user = @user_intake.send("#{user_type}".to_sym)
        user.email.should == "#{user_type}@example.com"
      end

    end
  end
    
  # saved records
  
  context "saved records" do

    # check each user type after save
    context "associations" do
      before(:each) do
        @user_intake = UserIntake.new
        @user_intake.skip_validation = true # just save user_intake + associations
        @user_intake.subscriber_is_user = false
        @user_intake.subscriber_is_caregiver = false
        @user_intake.no_caregiver_1 = false
        @user_intake.no_caregiver_2 = false
        @user_intake.no_caregiver_3 = false
        @user_intake.group = Group.create(:name => "group")
      end

      ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|
        it "should save the associations correctly" do
          add_senior if user_type != "senior" # when testing, senior is mandatory
          @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@example.com"))
          @user_intake.save

          @user_intake.new_record?.should be_false, "#{user_type}: senior=#{!@user_intake.senior.blank?}, subscriber=#{!@user_intake.subscriber.blank?}"
          @user_intake.send("#{user_type}".to_sym).new_record?.should be_false
          @user_intake.users.include?(@user_intake.send("#{user_type}".to_sym)).should be_true
          user =  @user_intake.send("#{user_type}".to_sym)
          user.email.should == "#{user_type}@example.com"
          user.roles.should_not be_blank
          user.roles.each { |e| e.new_record?.should be_false }
        end

        it "should not validate user intake without a senior profile" do
          @user_intake.skip_validation = false # validate
          @user_intake.senior = nil # remove senior
          @user_intake.should_not be_valid
          @user_intake.save
          @user_intake.errors.should_not be_blank
        end
        
        it "should have a #{user_type}" do
          add_senior if user_type != "senior" # when testing, senior is mandatory
          @user_intake.send("#{user_type}=".to_sym, User.new(:email => "#{user_type}@example.com"))
          @user_intake.save

          (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
          user = user_intake.send("#{user_type}".to_sym)
          user.should_not be_blank
          user.email.should == "#{user_type}@example.com"
        end

        it "should save profile for #{user_type}" do
          # user_hash = User.new(:email => "#{user_type}@example.com").attributes
          # local_profile_hash = profile_hash(user_type)
          # user_hash["profile_attributes"] = Profile.new(local_profile_hash).attributes
          user = build_user(user_type) # includes profile
          local_profile_hash = user.profile.attributes.reject {|k,v| k.include?('id') } # eliminate FKeys
          @user_intake.subscriber_is_user = !(user_type == 'subscriber') # force save subscriber
          @user_intake.no_caregiver_1 = !(user_type == 'caregiver1') # force save caregivers
          @user_intake.no_caregiver_2 = !(user_type == 'caregiver2')
          @user_intake.no_caregiver_3 = !(user_type == 'caregiver3')
          @user_intake.send("#{user_type}=".to_sym, user)
          add_senior if user_type != "senior" # senior is mandatory
          
          user = @user_intake.send("#{user_type}".to_sym)
          user.email.should == "#{user_type}@example.com"
          @user_intake.save

          (user_intake = UserIntake.find_by_id(@user_intake.id)).should_not be_blank, "#{@user_intake.errors.full_messages.join(',')}"
          (user = user_intake.send("#{user_type}".to_sym)).should_not be_blank
          profile = user.profile
          profile.should_not be_blank
          local_profile_hash.each {|k,v| profile.send("#{k}".to_sym).should == v }
        end
      end # each
    end # associations
    
    context "roles" do
      before(:each) do
        @user_intake = UserIntake.new
        @user_intake.group = Group.create(:name => "group")
        @user_intake.subscriber_is_user = true
        @user_intake.senior = build_user("senior")
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
        @user_intake = UserIntake.new
        @user_intake.group = Group.create(:name => "group")
        add_senior # assign senior profile
      end
      
      it "should have senior attributes for senior & subscriber, when senior is subscriber" do
        @user_intake.save

        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true
        user_intake.senior.email.should == "senior@example.com"
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
          user = user_intake.send("#{user_type}".to_sym)
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
        user_intake.subscriber.is_subscriber_of?(user_intake.senior).should be_true # subscriber.is_subscriber?
        user_intake.subscriber.is_caregiver_to?(user_intake.senior).should be_true # subscriber.is_caregiver?
        user_intake.caregiver1.email.should be(user_intake.subscriber.email) # caregiver1 == subscriber
        user_intake.subscriber.caregiver_position_for(user_intake.senior).should be(1) # subscriber == 1st caregiver
      end
      
      it "should have different profile for everyone. no overlapping roles" do
        @user_intake.subscriber_is_user = false
        add_subscriber
        add_caregivers # all caregivers are given. also marks no_caregiver_n to false.
        @user_intake.save
        (user_intake = UserIntake.find(@user_intake.id)).should_not be_blank
        user_intake.users.length.should be(5) # five users
        ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |user_type|
          user = user_intake.send("#{user_type}".to_sym)
          user.should_not be_nil
          user.email.should == "#{user_type}@example.com"
        end
        (1..3).each do |index|
          caregiver = user_intake.send("caregiver#{index}".to_sym)
          caregiver.should_not be_nil
          caregiver.caregiver_position_for(user_intake.senior).should == index
        end
      end
    end
        
  end # saved records
end #user intake
