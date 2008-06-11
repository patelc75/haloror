
 
require File.dirname(__FILE__) + '/../spec_helper'

describe Fall do
  
  before(:each) do
    curl_cmd = 'curl -v -H "Content-Type: text/xml" -d "<fall><magnitude>60</magnitude><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><user_id>1</user_id></fall>" "http://localhost:3000/falls?gateway_id=1&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"'
    puts curl_cmd
    system(curl_cmd)
    @fall = Fall.find(:first,:conditions=>"timestamp='Mon Dec 25 15:52:55 -0600 2007'")
    @ts = @fall.timestamp.to_s
  end

  it "should be equal " do
    Checking = "Tue Dec 25 15:52:55 UTC 2007"
    @ts.should == Checking.to_s
  end

end

