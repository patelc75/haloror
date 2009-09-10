class EventsController < ApplicationController
  before_filter :authenticate_admin_halouser_caregiver_operator?
  include UtilityHelper
  def user
    @user = User.find(params[:id])
    groups = @user.group_memberships
    if(@user.id == current_user.id || @current_user.patients.include?(@user) || @current_user.is_super_admin? || @current_user.is_admin_of_any?(groups) || @current_user.is_operator_of_any?(groups)) 
      conditions = "user_id = #{@user.id} "
      @user_begin_time = params[:begin_time]
      @user_end_time = params[:end_time]
      if  @user_end_time and @user_begin_time and params[:begin_time] != "" and params[:end_time] != ""
    	@end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
    	@begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
    	conditions += "and timestamp > '#{@begin_time}' and timestamp < '#{@end_time}' "
      end
      if params[:event_type] and params[:event_type] != ""
    	conditions += "and event_type = '#{params[:event_type]}'"
      end
    
      if params[:alert_group] and params[:alert_group] != ""
    	@alert_group = AlertGroup.find_by_group_type(params[:alert_group])
    	conditions += " and event_type IN ('0'"
    	for alert_type in @alert_group.alert_types
    		conditions += ",'#{alert_type.alert_type}'"
    	end
    	conditions += ")"
      end
      @events = Event.paginate :page => params[:page], 
				# :order => "(timestamp_server IS NOT NULL) DESC, timestamp_server DESC, timestamp DESC", 
			       :order => "timestamp DESC",
                               :conditions => conditions, 
                               :per_page => EVENTS_PER_PAGE
      render :layout => 'application'
    else
      redirect_to :action => 'unauthorized', :controller => 'security'
    end
  end
end
