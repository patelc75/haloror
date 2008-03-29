# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require File.dirname(__FILE__) + '/../spec_helper'

describe Fall do
  
  before(:each) do
    curl_cmd = 'curl -v -H "Content-Type: text/xml" -d "<fall><magnitude>60</magnitude><timestamp>Tue Dec 25 15:52:55 -0600 2007</timestamp><user_id>10</user_id></fall>" "http://localhost:3000/falls?gateway_id=1&auth=1b092333716e1204c973ec651cab4a6470acbb29fa1e94fca20a2ccd6bdde82a"'
    puts curl_cmd
    system(curl_cmd)
    @fall = Fall.find(:first,:conditions=>"timestamp='Tue Dec 25 15:52:55 -0600 2007'")
    @ts = @fall.timestamp.to_s
  end

  it "should be equal to nil " do
    Checking = "Tue Dec 25 15:52:55 -0600 2007"
    @ts.should == Checking.to_s
    #@testing.timestamp.should_not equal(nil)
  end

end

