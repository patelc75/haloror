class ReportingController < ApplicationController
  before_filter :authenticate_admin_moderator?
  include UtilityHelper
  
  def users
    @users = User.find(:all, :include => [:roles, :roles_users], :order => 'users.id')
    @roles = []
    rows = Role.connection.select_all("Select Distinct name from roles order by name asc")
    rows.collect do |row|
      @roles << row['name']
    end
    @groups = current_user.group_memberships
    @group_name = ''
    if !params[:group_name].blank?
      @group_name = params[:group_name]
      session[:group_name] = @group_name
      @group = Group.find_by_name(@group_name)
    end
    @user_names = {''=>''}
    
    @users.each do |user|
      if user
        @user_names[user.login] = user.id
      end
    end
  end
  
  def user_hidden
    @user = User.find(params[:user_id], :include => [:roles, :roles_users])
    render :partial => 'user_hidden', :layout => false
  end
  
  def devices
    conditions = ''
    if !current_user.is_super_admin?
      groups = current_user.group_memberships
      g_ids = []
      groups.each do |group|
        g_ids << group.id if(current_user.is_admin_of?(group))
      end
      group_ids = g_ids.join(', ')
      RAILS_DEFAULT_LOGGER.warn(group_ids)
      conditions = "devices.id IN (Select device_id from devices_users where devices_users.user_id IN (Select user_id from roles_users INNER JOIN roles ON roles_users.role_id = roles.id where roles.id IN (Select id from roles where authorizable_type = 'Group' AND authorizable_id IN (#{group_ids}))))"
    end
    if conditions.blank?
      @devices = Device.find(:all, :order => "id asc")
    else
      @devices = Device.find(:all, :order => "id asc",
                                  :conditions => conditions)
    end
  end
  
  def device_hidden
    @device = Device.find(params[:device_id])
    render :partial => 'device_hidden', :layout => false
  end
  def sort_user_table
    #order = "#{params[:col]} asc"
    
    #users = User.find(:all, :order => order)
    
    if params[:col] == 'name'
      users = User.find(:all, :include => :profile, :order => 'profiles.last_name')
    else
      users = User.find(:all, :order => params[:col])
    end
    @group_name = ''
    if !session[:group_name].blank?
      @group_name = session[:group_name]
      @group = Group.find_by_name(@group_name)
    end
    sortby = 'id'
    
    render :partial => 'user_table', :locals => {:users => users, :sortby => params[:col], :reverse => false}
  end
  
  def search_user_table
    users = User.find(:all, :conditions => "login like '%#{params[:query]}%' or first_name like '%#{params[:query]}%' or last_name like '%#{params[:query]}%'",:include => [ :profile ])
        
    render :partial => 'user_table', :locals => {:users => users, :sortby => 'id', :reverse => false}
  end
  
  def summary
    @critically_low = Battery.find(:all, :conditions => "time_remaining < 10")
  end
  
  def critical_event_data
    @periods = {}
    
    i = 0
    now = Date.today.to_time
    while i < 30
      time = now.ago(i*86400)
      data = {}
      data[:falls] = Event.find(:all, :conditions => "timestamp > '#{time}' and timestamp < '#{time.tomorrow}' and event_type = 'Fall'").length
      data[:panics] = Event.find(:all, :conditions => "timestamp > '#{time}' and timestamp < '#{time.tomorrow}' and event_type = 'Panic'").length
      @periods[time] = data
      i += 1
    end
    
    render :layout => false
  end
  def lost_data_summary
    @user = current_user
    @users = []
    @end_time = params[:end_time]
    @begin_time = params[:begin_time]
    if !@end_time.blank? && !@begin_time.blank?
      @end_time = @end_time.to_time
      @begin_time = @begin_time.to_time
      user_ids = LostData.user_ids_with_lost_data(@begin_time, @end_time)
      if user_ids && user_ids.size > 0
        @users = User.find(:all, :conditions => "users.id IN (#{user_ids.join(',')})", :include => [:roles, :roles_users, :access_logs, :profile])
      end 
    else
      flash[:warning] = 'Begin Time and End Time are required.'
    end   
  end
  def lost_data
    if user_id = params[:id]
      @user = User.find(user_id)
      DailyReports.lost_data_scan(user_id)      
      @lost_data = LostData.paginate(:page => params[:page], :per_page => 50, :conditions => "user_id = #{user_id}", :order => "id desc")
    else
      redirect_to '/'
    end    
  end
  def lost_data_daily
    
  end
  def remove_user_mapping
    user_id = params[:id]
    device_id = params[:device_id]
    Device.connection.delete "delete from devices_users where device_id = #{device_id} and user_id = #{user_id} "
    if params[:users].blank?
      redirect_to '/reporting/devices'
    else
      redirect_to '/reporting/users'
    end
  end
  
  def init_strap_not_worn
    render :partial => 'init_strap_not_worn', :layout => true
  end
  def strap_not_worn
    @end_time = params[:end_time]
    @begin_time = params[:begin_time]
    if !@end_time.blank? && !@begin_time.blank?
      @end_time = @end_time.to_time
      @begin_time = @begin_time.to_time
      @users, @total_lost_data, @total_not_worn = DailyReports.device_not_worn_halousers(@begin_time, @end_time)
    else
      flash[:warning] = 'Begin Time and End Time are required.'
      render :partial => 'init_strap_not_worn', :layout => true
    end    
  end
  
  def init_successful_user_logins
    render :partial => 'init_successful_user_logins', :layout => true
  end
  def successful_user_logins
    @end_time = params[:end_time]
    @begin_time = params[:begin_time]
    if !@end_time.blank? && !@begin_time.blank?
      @end_time = @end_time.to_time
      @begin_time = @begin_time.to_time
      @users = DailyReports.successful_user_logins(@begin_time, @end_time)
    else
      flash[:warning] = 'Begin Time and End Time are required.'
      render :partial => 'init_successful_user_logins', :layout => true
    end
  end
end