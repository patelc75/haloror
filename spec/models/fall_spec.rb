require File.dirname(__FILE__) + '/../spec_helper'

describe Fall do
  
  before(:all) do
    @no_records = Fall.count
    fall = Fall.new
    user = User.find_by_login(USER)
    fall.user_id = user.id
    fall.magnitude = 60
    gateway = user.devices.find(:first, :conditions => "device_type = '#{HALO_GATEWAY}'")
    timestamp = set_timestamp(fall)
    auth = generate_auth(timestamp, gateway.id)
    
    curl_cmd = BEGIN_CURL 
    curl_cmd += '"'
    curl_cmd += get_xml(fall)
    curl_cmd += '" '
    curl_cmd += '"http://'
    curl_cmd += SITE_URL
    curl_cmd += '/falls'
    curl_cmd += '?gateway_id=' + gateway.id.to_s
    curl_cmd += '&auth=' + auth
    curl_cmd += '"'
    puts curl_cmd
    `#{curl_cmd}`
  end

  it "should have one more fall" do
    Fall.should have(@no_records + 1).records
  end

end

