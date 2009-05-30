require File.dirname(__FILE__) + '/../spec_helper'

describe BundleJob do
	before(:all) do
	  BUNDLE_PATH = "#{RAILS_ROOT}/dialup"
		Dir.mkdir(BUNDLE_PATH) unless File.exists?(BUNDLE_PATH)
		FileUtils.cp "#{RAILS_ROOT}/spec/H200000023_1240876150.tar.bz2","#{RAILS_ROOT}/dialup"
		BundleJob.job_process_bundles
		@battery = Battery.count(:conditions => ["user_id = ?",44])
	end

	it "should have 94 batteries" do
	@battery.should == 94
	end

	it "should have 1 battery_unplugged" do
	BatteryUnplugged.count(:conditions => ["user_id = ?",44]).should == 1
	end

	it "should have 93 vitals" do
	Vital.count(:conditions => ["user_id = ?",44]).should == 93
	end
	
	it "should have 93 steps" do
	Step.count(:conditions => ["user_id = ?",44]).should == 93
	end
	
	it "should have 93 skin_temps" do
	SkinTemp.count(:conditions => ["user_id = ?",44]).should == 93
	end
	
end