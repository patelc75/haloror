require File.join( RAILS_ROOT, 'spec', 'spec_helper')

describe TriageThreshold do
  before(:each) do
    @valid_attributes = {
      :group_id => Group.create(:name => "group1").id,
      :type => "value for type",
      :battery_percent => 1
    }
  end

  it "should create a new instance given valid attributes" do
    TriageThreshold.create!(@valid_attributes)
  end
end
