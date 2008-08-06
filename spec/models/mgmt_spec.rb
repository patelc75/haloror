require File.dirname(__FILE__) + '/../spec_helper'

describe MgmtQuery do  
  before(:all) do
    #@no_records = 0
    #CLAZZES.each do |clazz|
    #@no_records += clazz.count
    mgmt_query = MgmtQuery.new_initialize()
    curl_cmd = get_curl_cmd(mgmt_query)
    puts curl_cmd
    #the response from the server should be sent to server_response
    server_response = `#{curl_cmd}`
  end
  
  it "should have one more of each model" do
    #    num_records = 0
    #    CLAZZES.each do |clazz|
    #      num_records += clazz.count
    #    end
    #    num_records.should be(@no_records + CLAZZES.size)
  end
end


#curl -v -H "Content-Type: text/xml" -d 
#"<management_query_device>
#   <device_id>1</device_id>
#   <timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp>
#   <poll_rate>60</poll_rate>
#</management_query_device>" 
#"http://localhost:3000/mgmt_queries?gateway_id=1&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"

#"<management_cmd_server>
#   <cmd_type>info</cmd_type>
#   <device_id>1</device_id>
#   <timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp>
#</management_cmd_server>" 