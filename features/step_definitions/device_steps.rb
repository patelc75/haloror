Then /^device "([^\"]*)" should have data for (.+)$/ do |_number, _method_names|
  _methods = _method_names.split(',').collect(&:strip).collect(&:to_sym) # array of method names as symbols
  (_device = Device.find_by_serial_number(_number)).should_not be_blank
  
  _methods.each {|_method| _device.send(_method).should_not be_blank } # send each method to get not_blank value
end

Then /^device "([^"]*)" should have only one current and new software version$/ do |_serial|
  (_device = Device.find_by_serial_number(_serial)).should_not be_blank
  DeviceInfo.all( :conditions => { :device_id => _device.id, :software_version_current => true }).length.should == 1
  DeviceInfo.all( :conditions => { :device_id => _device.id, :software_version_new     => true }).length.should == 1
end
