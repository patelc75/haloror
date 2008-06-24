ENV["RAILS_ENV"] = "development"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'

dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/steps/*.rb")].uniq.each do |file|
  require file
end

##
# Run a story file relative to the stories directory.

def run_local_story(filename, options={})
  run File.join(File.dirname(__FILE__), filename), options
end


#DEVICE_REGISTRATION_COMMAND='curl -H "Content-Type: text/xml" -d "<management_cmd_device><device_id>1</device_id><cmd_type>device_registration</cmd_type><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><originator>server</originator></management_cmd_device>" "http://localhost:3000/mgmt_acks?gateway_id=1&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"'
