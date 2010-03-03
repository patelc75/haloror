# bundle_job specific steps
#

When /^I process the bundle job "([^\"]*)"$/ do |file_offset_path|
  BUNDLE_PATH = "#{RAILS_ROOT}/dialup"
	Dir.mkdir(BUNDLE_PATH) unless File.exists?(BUNDLE_PATH)
	FileUtils.cp "#{RAILS_ROOT}/#{file_offset_path}","#{RAILS_ROOT}/dialup"
	BundleJob.job_process_bundles
end
