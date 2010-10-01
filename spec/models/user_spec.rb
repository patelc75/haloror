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
end
