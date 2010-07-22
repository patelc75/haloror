module UsersHelper

  # alert button tag
  # Usage: specify options, as many as possible. its a hash anyways
  #   alert_button( :type => "caution")
  #   alert_button( :type => "caution", :id => user.id)
  #   alert_button( :type => "caution", :path => path_for{ :controller => 'users', :action => 'test'})
  def alert_button( options = {})
    options.reverse_merge( {:type => 'normal', :path => '#', :id => Time.now.to_i, :size => 'medium'})
    # button types and colors
    buttons = {"normal" => "green-button", "caution" => "orange-button", "abnormal" => "red-button", "test mode" => "blue-button"}
    options[:type] = "normal" unless buttons.keys.include?( options[:type]) # only these types allowed
    options[:size] = ' medium' unless options[:size] =~ /medium|small|bigrounded/
    # TODO: fix this properly
    # https://redmine.corp.halomonitor.com/issues/3202
    # dynamically generate HTML using markaby gem
    # markaby do
    #   a :href => "#{path}", :class => "button #{buttons[type]} #{size}" do
    #     strong do
    #       type.upcase.gsub(' ','.')
    #     end
    #   end
    # end
    "<a href=\"#{options[:path]}\" class=\"button #{buttons[options[:type]]} #{options[:size]}\" id=\"alert_#{options[:id]}\">
      <strong>#{options[:type].upcase.gsub(' ','.')}</strong>
    </a>"
  end

  def links_for_user(user = nil)
    links = []
    if !user.blank? && user.is_a?(User)
      unless user.profile.blank?
        links << ['Profile', url_for(:controller => "profiles", :action => "edit_caregiver_profile", :id => user.profile.id, :user_id => user.id)]
        links << ['Caregivers', url_for(:controller => 'call_list', :action => 'show', :id => user.id)]
        # TODO: need to implement a non-ajax version of this link
        # links << ['Start Range Test', url_for(:controller => 'installs', :action => 'start_range_test_only_init', :id => user.id)]
        links << ['Events', "/events/user/#{user[:id]}"]
        links << ['Chart', "/chart/flex/#{user[:id]}"]
        links << ['Notes', url_for(:controller => 'call_center', :action => 'all_user_notes', :id => user[:id], :user_id => user[:id])]
        if current_user.is_super_admin?
          links << ['Compliance', "/reporting/compliance_report/#{user[:id]}"]
          links << ['Vitals List', "/blood_pressures?id=#{user.id}"]
          links << ['Subscription', subscription_path(user.subscriptions.first)] if (user.subscriptions.length > 0)
        end
      end
    end
    links
  end
end