# bundle_job specific steps
#

# process bz2 file that has many XML files
#
When /^I process the bundle job "([^\"]*)"$/ do |file_offset_path|
  BUNDLE_PATH = "#{RAILS_ROOT}/dialup"
	Dir.mkdir(BUNDLE_PATH) unless File.exists?(BUNDLE_PATH)
	FileUtils.cp "#{RAILS_ROOT}/#{file_offset_path}","#{RAILS_ROOT}/dialup"
	BundleJob.job_process_bundles
end

# process single XML file by offset path
#
When /^I process the xml file "([^\"]*)"$/ do |file_offset_path|
  BundleJob.process_xml_file(file_offset_path)
end

Then /^I do not see "([^\"]*)" folder$/ do |folder_offset|
  File.exist?(folder_offset).should be_false # rspec matchers
end