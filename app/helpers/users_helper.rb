module UsersHelper

  # alert button tag
  def alert_button(type = "normal", path = "#", size = "medium", options = {})
    # button types and colors
    buttons = {"normal" => "green-button", "caution" => "orange-button", "abnormal" => "red-button", "test mode" => "blue-button"}
    type = "normal" unless buttons.keys.include?(type) # only these types allowed
    size = (size.blank? ? 'medium' : size)
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
    "<a href=\"#{path}\" class=\"button #{buttons[type]} #{size}\" id=\"alert_#{options[:id]}\">
      <strong>#{type.upcase.gsub(' ','.')}</strong>
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