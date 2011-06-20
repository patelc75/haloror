require File.join( RAILS_ROOT, 'spec', 'spec_helper')

describe TriageAuditLog do
  before(:each) do
    @valid_attributes = {
      :user_id => Factory.create(:user).id,
      :is_dismissed => false,
      :description => "value for description"
    }
  end

  it "should create a new instance given valid attributes" do
    TriageAuditLog.create!(@valid_attributes)
  end
end
