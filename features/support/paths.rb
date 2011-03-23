module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
    when /the new bundle_processor page/
      new_bundle_processor_path

    when /new user_intake page/
      new_user_intake_path
      
    when /the user intake overview/
      user_intakes_path
      
    when /call list/
      "call_list/show/#{current_user.id}"

    when /the bestbuy store/
      bestbuy_store_path
      
    when /the online store/
      store_path
      
    when /the triage page/
      triage_path
      
    when /the login page/
      login_path
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
