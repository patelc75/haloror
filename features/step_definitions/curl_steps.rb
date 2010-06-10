
When /^I post the following for user "([^\"]*)":$/ do |user_login, table|
  # fetch values and keys from the table
  options = {}
  table.raw.each {|name, value| options[name.gsub(/ /,'_').downcase.singularize.to_sym] = value }

  user = User.find_by_login(user_login)
  user.should_not be_blank

  # load data for POST
  xml_string = File.read(File.join(Rails.root, "spec", "data", "curl", options[:file_name]))
  xml_string.should_not be_blank
  xml_string.gsub!("meta_user_id", user.id.to_s) # replace user ID with our user
  path = "#{options[:path]}?gateway_id=0&auth=#{options[:auth_key]}"
  
  post( path, xml_string, {"Content-type" => "text/xml"}) # POST XML content
end
