require "nokogiri"

# 
#  Fri Feb 18 01:28:37 IST 2011, ramonrails
#   * better method than the other one present here. this one has very flexible syntax
#   * accepts login / email for user identification
When /^I post the following XML:$/ do |table|
  # fetch values and keys from the table
  options = {}
  table.raw.each {|name, value| options[name.gsub(/ /,'_').downcase] = ( value.include?('`') ? eval(value.gsub('`','')).to_s : value) }

  #   * manadatory keys
  options['timestamp'] = Time.now.to_s unless options.has_key?('timestamp') # ensure timestamp
  #   * just create device here. device_id will be added to options in the next step called from here
  unless options.has_key?( 'device') # ensure device
    options['device'] = 'H123456789'
    Factory.create( :device, :serial_number => options['device']) if Device.find_by_serial_number( options['device'] ).blank?
  end
  #   * fetch device, if given. otherwise fetch default device
  (device = Device.find_by_serial_number( options['device'] )).should_not be_blank
  options['device_id'] = device.id # this value gets replaced in the XML node
  #   * generate authorization key
  options['auth_key'] = Digest::SHA256.hexdigest( options['timestamp'] + options['device'])

  #   * fetch user instance from given login or email
  if options.has_key?('user')
    (user = User.contains( options['user'] ).first).should_not be_blank
    options['user_id'] = user.id # this value will get replaced in the XML node
  end
  
  #   * read XML file
  #   * replace the data in nodes from the given values in table
  doc = Nokogiri::XML( File.read( File.join( Rails.root, "spec", "data", "curl", options['file_name'] )))
  doc.should_not be_blank
  #   * except these 3, all other keys are the node name
  #   * replace the data of given nodes, if they are found in the XML
  if (_meta = options.keys.reject {|e| ['file_name', 'path', 'auth_key'].include?(e) })
    _meta.each do |_key|
      if ( _node = doc.at_xpath( "//#{_key}")) # find the node with the key in given table
        _node.content = options[_key] # replace the value from table data
      end
    end
  end
  xml_string = doc.to_xml # convert the XML back to string
  #   * generate a path for POST
  path = "#{options['path']}?gateway_id=#{device.id}&auth=#{options['auth_key']}"
  
  post( path, xml_string, {"Content-type" => "text/xml"}) # POST XML content
end

# 
#  Thu Feb 17 23:56:18 IST 2011, ramonrails
#   * now uses nokogiri
#   * considers all keys except "file_name", "path", "auth_key" from the given table, as data nodes
#   * replaces the content of the nodes (if found) with the data given in the table
#   * DEPRECATED:  In favour of the new method above. Please check the usage before removing
When /^I post the following for (user|device) "([^\"]*)":$/ do |_type, _type_data, table|
  # fetch values and keys from the table
  options = {}
  table.raw.each {|name, value| options[name.gsub(/ /,'_').downcase] = value }

  case _type
  when 'user'
    (user = User.find_by_login(_type_data)).should_not be_blank
  when 'device'
    (device = Device.find_by_serial_number(_type_data)).should_not be_blank
  end
  
  #   * do not fetch device if, already defined + not blank
  unless defined?( device) && !device.blank?
    (device = Device.find_by_serial_number( options.has_key?('device') ? options['device'] : "H123456789")).should_not be_blank
  end

  # load data for POST
  # doc = Nokogiri::XML( File.read(File.join(Rails.root, "spec", "data", "curl", options[:file_name])) )
  # doc.should_not be_blank
  # #   * except these 3, all other can be node names
  # if (_meta = options.keys.reject {|e| ["file_name", "path", "auth_key"].include?(e) })
  #   _meta.each do |_key|
  #     if ( _node = doc.at_xpath( "//#{_key}")) # find the node with the key in given table
  #       _node.content = options[_key] # replace the value from table data
  #     end
  #   end
  # end
  # xml_string = doc.to_xml
  
  xml_string = File.read(File.join(Rails.root, "spec", "data", "curl", options['file_name']))
  xml_string.should_not be_blank
  xml_string = xml_string.gsub("meta_user_id", user.id.to_s) # replace user ID with our user
  xml_string = xml_string.gsub("meta_device_id", device.id.to_s) # replace device_id with actual device
  
  path = "#{options['path']}?gateway_id=#{device.id}&auth=#{options['auth_key']}"
  
  post( path, xml_string, {"Content-type" => "text/xml"}) # POST XML content
end
