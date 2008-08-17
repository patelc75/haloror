class EventsController < ApplicationController
  include UtilityHelper
  def user
    @user = User.find(params[:id])
    if(@user.id == current_user.id || @current_user.patients.include?(@user) || current_user.is_administrator?) 
      conditions = "user_id = #{@user.id}"
      total = Event.count(:conditions => conditions)
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
