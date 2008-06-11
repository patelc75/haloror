
 

require File.dirname(__FILE__) + '/../spec_helper'

describe Panic do
  
  before(:each) do
    curl_cmd = 'curl -v -H "Content-Type: text/xml" -d "<panic><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><user_id>1</user_id></panic>" "http://localhost:3000/panics?gateway_id=1&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"'
    puts curl_cmd
    system(curl_cmd)
    @panic = Panic.find(:first,:conditions=>"timestamp='Mon Dec 25 15:52:55 -0600 2007'")
    @tspanic = @panic.timestamp.to_s
  end

  
  
  it "should be equal" do
    Assumingdata = "Tue Dec 25 15:52:55 UTC 2007"
    @tspanic.should == Assumingdata.to_s
  end

end