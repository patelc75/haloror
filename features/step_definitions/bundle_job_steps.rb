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

When /^I process the curl text file "([^\"]*)"$/ do |text_file|
  curl = []
  debugger
  File.open(text_file).each_line {|line| curl << line }
  # create a hash from XML data
  xml_hash = Hash.from_xml(curl[2])
  # make sure the user_id referred in the XML, exist in database
  user_ids = recursively_search_hash(xml_hash, "user_id")
  user_ids.each {|p| Factory.create(:user, :id => p.to_i) if User.find_by_id(p.to_i).blank? }
  # now run the CURL at system level
  system("curl #{curl[0]} '#{curl[2]}' '#{curl[1]}'".gsub(/\n/,''))
  
  # unless (xml_string = File.read(text_file)).blank?
  #   unless (bundle_hash = Hash.from_xml(xml_string)).blank?
  #     debugger
  #     #
  #     # make sure the user_id referred in the XML, exist in database
  #     user_ids = recursively_search_hash(bundle_hash, "user_id")
  #     user_ids.each {|p| Factory.create(:user, :id => p.to_i) if User.find_by_id(p.to_i).blank? }
  #     #
  #     # now process the XML hash
  #     BundleProcessor.process(bundle_hash["curl_data"])
  #   end
  # end
end

Then /^I do not see "([^\"]*)" folder$/ do |folder_offset|
  File.exist?(folder_offset).should be_false # rspec matchers
end