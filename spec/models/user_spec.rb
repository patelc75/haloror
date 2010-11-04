require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe User do
  before(:each) do
    @user = Factory.create(:user)
    @user_mem = Factory.build(:user)
  end
  
  context "User saved properties" do
    subject { @user }
    it { should be_valid }
  end
  
  context "role user options - hash" do
    before(:each) do
      @senior = Factory.create( :user, :login => "senior")
      @caregiver = Factory.create( :user, :login => "caregiver")
      @relation = Faker::Name.name
      @caregiver.options_for_senior( @senior, {:relationship => @relation})
    end
    
    specify { @caregiver.options_for_senior( @senior).relationship.should == @relation}
  end

  context "role user options - roles_users_option" do
    before(:each) do
      @senior = Factory.create( :user, :login => "senior")
      @caregiver = Factory.create( :user, :login => "caregiver")
      @relation = Faker::Name.name
      @caregiver.options_for_senior( @senior, RolesUsersOption.new( {:relationship => @relation} ))
    end
    
    specify { @caregiver.options_for_senior( @senior).relationship.should == @relation}
  end
end
