require File.join(File.dirname(__FILE__), "..", "spec_helper")

describe UserLog do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :log => "value for log"
    }
  end

  it "should create a new instance given valid attributes" do
    UserLog.create!(@valid_attributes)
  end
end
