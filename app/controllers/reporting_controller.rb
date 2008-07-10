class ReportingController < ApplicationController
  include UtilityHelper
  LOST_DATA_GAP = 15.seconds
  
  def users
    @users = User.find(:all, :include => [:roles, :roles_users])
    @roles = ['administrator', 'operator', 'caregiver', 'halouser']
    
    @user_names = {''=>''}
    
    User.find(:all).each do |user|
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
    @devices = Device.find(:all)
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
      users = User.find(:all, :include => :profile, :order => params[:col])
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
    if !params[:lost_data].blank?
      @lost_data = LostData.new(params[:lost_data])
      begin_time = @lost_data.begin_time
      end_time = @lost_data.end_time
      user_ids = LostData.user_ids_with_lost_data(begin_time, end_time)
      if user_ids && user_ids.size > 0
        @users = User.find(:all, :conditions => "users.id IN (#{user_ids.join(',')})", :include => [:roles, :roles_users, :access_logs, :profile])
      end 
    end   
  end
  def lost_data
    if user_id = params[:id]
      @user = User.find(user_id)
      prev_timestamp = nil
      
      if last = VitalScan.find(:first, :conditions => "user_id = #{user_id}", :order => "timestamp desc")
        conds = " and timestamp > '#{last.timestamp.to_s(:db)}'"
      else
        conds = ""
      end
      
      Vital.find(:all, :order => 'timestamp asc', :conditions => "user_id = #{user_id}#{conds}").each do |reading|
        if prev_timestamp and (reading.timestamp - prev_timestamp) > LOST_DATA_GAP
          # create row in lost_data table
          lost = LostData.new
          lost.user_id = reading.user_id
          lost.begin_time = prev_timestamp
          lost.end_time = reading.timestamp
          lost.save
        end
      
        prev_timestamp = reading.timestamp
      end
      
      if (!last or prev_timestamp != last.timestamp) and !prev_timestamp.nil?
        last = VitalScan.new
        last.user_id = user_id
        last.timestamp = prev_timestamp
        last.save
      end
      
      @lost_data = LostData.find(:all, :conditions => "user_id = #{user_id}", :order => "id desc")
    else
      redirect_to '/'
    end    
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
end