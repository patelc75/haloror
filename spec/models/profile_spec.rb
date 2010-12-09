require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe Profile do
  context "in-memory" do
    before(:each) { @profile = Factory.build( :profile) }
    specify { @profile.should be_valid }
    specify { @profile.carrier.should be_valid }
  end
  
  context "saved records" do
    before(:each) { @profile = Factory.create( :profile) }
    specify { @profile.should be_valid }
    specify { @profile.carrier.should be_valid }
  end
  
  context "saved records - attributes" do
    before(:each) do
      profile = Profile.new( Factory.build( :profile).attributes )
      profile.save
      @profile = Profile.find( profile.id)
    end
    specify { @profile.should be_valid }
    specify { @profile.carrier.should be_valid }
  end
  
  # 
  #  Fri Dec 10 00:10:42 IST 2010, ramonrails
  #   * halouser with blank account numbers get the next available numbers
  context "halousers with blank account numbers, given at least one account number exist" do
    before(:all) do
      @user_ids = []
      Factory.create( :user) # to create the first account number. otherwise everybody gets ????
      5.times do
        _user = Factory.create( :user) # get user
        _user.profile.update_attribute( :account_number, nil)
        _user.is_halouser # assign role
        @user_ids << _user.id # collect for checking
      end
    end
    
    5.times.with_index do |n,i|
      it "get 4-digit account number when profile gets saved" do
        _users = User.find( @user_ids)
        _users[n].profile.save.should be_true
        _users[n].profile.account_number.should_not be_blank
        _users[n].profile.account_number.should =~ /^(\d{4})$/
      end
    end
  end

  # 
  #  Fri Dec 10 00:31:48 IST 2010, ramonrails
  #   * no valid account numbers exist
  #   * all new halousers will get ????
  context "halousers with blank account numbers, given no valid account number exist" do
    before(:all) do
      @user_ids = []
      5.times do
        _user = Factory.create( :user) # get user
        _user.profile.update_attribute( :account_number, nil)
        _user.is_halouser # assign role
        @user_ids << _user.id # collect for checking
      end
    end
    
    5.times.with_index do |n,i|
      it "get ???? account number when profile gets saved" do
        _users = User.find( @user_ids)
        _users[n].profile.save.should be_true
        _users[n].profile.account_number.should_not be_blank
        _users[n].profile.account_number.should == "????"
      end
    end
  end

  # 
  #  Fri Dec 10 00:11:10 IST 2010, ramonrails
  #   * Existing account numbers are not overwritten
  context "halousers with exisitng account numbers HM...." do
    before(:all) do
      @users = []
      @user_ids = []
      5.times do
        _user = Factory.create( :user) # get user
        _user.profile.update_attribute( :account_number, "HM#{'%04d' % rand(9999)}")
        _user.is_halouser # assign role
        @users << _user
        @user_ids << _user.id # collect for checking
      end
    end
    
    5.times.with_index do |n,i|
      it "does not overwrite existing HM.... account numbers" do
        _users = User.find( @user_ids)
        _users[n].profile.save.should be_true
        _users[n].profile.account_number.should == @users.select {|e| e.id == _users[n].id }.first.profile.account_number
      end
    end
  end
  
  # 
  #  Fri Dec 10 00:24:15 IST 2010, ramonrails
  #   * non-halousers never get account number
  context "non-halousers" do
    before(:all) do
      @user_ids = []
      5.times do
        _user = Factory.create( :user) # get user
        _user.profile.update_attribute( :account_number, nil) # empty. gets auto created by factory_girl
        @user_ids << _user.id # collect for checking
      end
    end
    
    5.times.with_index do |n,i|
      it "never get account number when profile gets saved" do
        _users = User.find( @user_ids)
        _users[n].profile.save.should be_true
        _users[n].profile.account_number.should be_blank
      end
    end
  end

end
