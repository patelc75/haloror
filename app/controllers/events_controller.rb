class EventsController < ApplicationController
  before_filter :authenticate_admin_halouser_caregiver_operator?
  include UtilityHelper
  
  # def index
  #   @events = Panic.paginate :page => params[:page], :per_page => 15
  # end
  
  def show
    _row = Event.find( params[:id])
    @event = if _row.panic?
      Panic.find( _row.event)
    elsif _row.fall?
      Fall.find( _row.event)
    end
    if @event.blank?
      @location, @zoom = 'U.S.A.', '3'
    else
      @location, @zoom = (@event.coordinates || @event.location), '14'
    end
    
    # 
    #  Mon Jun 13 22:22:01 IST 2011, ramonrails
    #   * also do a map through gem
    @map = GMap.new( "map_div")
    @map.control_init( :large_map => true, :map_type => true)
    @map.set_map_type_init( GMapType::G_HYBRID_MAP)
    @map.center_zoom_init( @event.location, 10)
    @map.overlay_init( GMarker.new( @event.location, :title => @event.user.name, :info_window => @event.user.location))
  end
  
  def user
    @alert_types = AlertType.types_as_array.sort
    @alert_types.delete("GwAlarmButtonTimeout")  
    @alert_types.delete("BatteryCritical")      
    
    @user = User.find(params[:id])
    groups = @user.group_memberships
    if(@user.id == current_user.id || @current_user.patients.include?(@user) || @current_user.is_super_admin? || @current_user.is_admin_of_any?(groups) || @current_user.is_operator_of_any?(groups)) 
      # update -- if params[:id] is a caregiver, then events shouldbe searched for the first halouser he/she is caregiving
      if @user.is_halouser?
        conditions = "user_id = #{@user.id} "
      elsif @user.is_caregiver?
        conditions = "user_id = #{@user.patients.first.id} " unless @user.patients.blank?
      else
        conditions = " "
      end
      # -- end of update--
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
      unless current_user.is_admin? or current_user.is_super_admin?
        @user_events = Event.find(:all,:conditions => conditions)
        @collect_events = @user_events.collect{|e| e.id if e.event_type != 'EventAction'}
        @events = Event.paginate :page => params[:page], 
				# :order => "(timestamp_server IS NOT NULL) DESC, timestamp_server DESC, timestamp DESC", 
			       :order => "timestamp DESC",
                   :conditions => ["id in (?)",@collect_events], 
                   :per_page => EVENTS_PER_PAGE
	  else
	    @events = Event.paginate :page => params[:page], 
				# :order => "(timestamp_server IS NOT NULL) DESC, timestamp_server DESC, timestamp DESC", 
			       :order => "timestamp DESC",
                               :conditions => conditions, 
                               :per_page => EVENTS_PER_PAGE	
      end
      render :layout => 'application'
    else
      redirect_to :action => 'unauthorized', :controller => 'security'
    end    
  end
end
