module NavigationHelpers
  # Maps a description to a CSS selector id, <element> or .class. Used by the
  #
  #   When /^... within (.+)$/ do |selector_name|
  #
  # step definition in general_steps.rb
  #
  def scope_of(scope_name)
    case scope_name
    
    when /the (page|html|head|body)$/i
      case $1
      when html, page
        'HTML'
      else
        $1.upcase
      end
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      '#' + scope_name.downcase.gsub(/ /,'_') # default = element id, underscored, lowercase
    end
  end
end

World(NavigationHelpers)
