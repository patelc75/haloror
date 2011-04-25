module CallListHelper
  def caregivers_list_header
    _data = []
    if @user.profile.blank?
      _data << link_to( "#{@user.name}'s", "#")
    else
      _data << link_to( @user.name + "'s", :controller => "profiles", :action => "edit_caregiver_profile", :id => @user.profile.id, :user_id => @user.id)
    end
    _data << 'Caregivers'
    _data.join(' ')
  end
end
