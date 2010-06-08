require File.join(File.dirname(__FILE__), "..", "spec_helper")
# require File.join(File.dirname(__FILE__), "..", "..", "test", "factories", "factories")

describe Group do
  before(:each) do
    @group = Factory.create(:group)
  end
  
  context 'creating group' do
    subject { @group }
    it { should be_valid }
  end
  
  context 'triage threshold values' do
    subject { @group.triage_thresholds }
    it { should_not be_blank }
  end

  specify { @group.new_record?.should be_false }
  specify { @group.triage_thresholds.first.should be_valid }
end