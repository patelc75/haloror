# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require File.dirname(__FILE__) + '/../spec_helper'

describe Panic do
  
  before(:each) do
#curl_cmd = 'curl -v -H "Content-Type: text/xml" -d "<fall><magnitude>60</magnitude><timestamp>Mon May 07 15:52:55 -0600 2007</timestamp><user_id>71</user_id></fall>" http://localhost:3000/falls'    
#curl_cmd = 'curl -v -H "Content-Type: text/xml" -d "<fall><magnitude>60</magnitude><timestamp>2007-12-24 14:52:55-06</timestamp><user_id>71</user_id></fall>" http://localhost:3000/falls'     
    
    curl_cmd = 'curl -v -H "Content-Type: text/xml" -d "<panic><timestamp>2007-12-24 14:52:55-06</timestamp><user_id>71</user_id></panic>" http://localhost:3000/panics'
    puts curl_cmd
    system(curl_cmd)
    @testingpanic = Panic.find(:first,:conditions=>"timestamp='Mon Dec 24 14:52:55 -0600 2007'")
     #@testingpanic = Panic.find(:first,:conditions=>"user_id='71'",:order => "timestamp DESC")
     @tspanic = @testingpanic.timestamp.to_s
  end

  
  
  it "should be equal to nil " do
    
    puts "Hello World"
    Assumingdata = "Mon Dec 24 14:52:55 -0600 2007"
  @tspanic.should == Assumingdata.to_s
  #@testing.timestamp.should_not equal(nil)
  end

end