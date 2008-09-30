class EventsController < ApplicationController
  before_filter :authenticate_admin_halouser_caregiver_operator?
  include UtilityHelper
  def user
    @user = User.find(params[:id])
    groups = @user.group_memberships
    if(@user.id == current_user.id || @current_user.patients.include?(@user) || @current_user.is_super_admin? || @current_user.is_admin_of_any?(groups) || @current_user.is_operator_of_any?(groups)) 
      conditions = "user_id = #{@user.id}"
      @events = Event.paginate :page => params[:page], 
                               :order => "(timestamp_server IS NOT NULL) DESC, timestamp_server DESC, timestamp DESC", 
                               :conditions => conditions, 
                               :per_page => EVENTS_PER_PAGE
      render :layout => 'application'
    else
      redirect_to :action => 'unauthorized', :controller => 'security'
    end
  end
end
