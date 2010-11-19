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
end
