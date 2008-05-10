class ReportingController < ApplicationController
  def users
    @users = User.find(:all, :include => [:roles, :roles_users, :access_logs, :profile, {:devices => :battery_charge_completes}])
  end
  
  def devices
    @devices = Device.find(:all, :include => [:battery_charge_completes, {:users => [:roles, :roles_users, :access_logs, :profile]}])
  end
  
  def sort_user_table
    #order = "#{params[:col]} asc"
    
    #users = User.find(:all, :order => order)
    users = User.find(:all)
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
      data[:falls] = Event.find(:all, :include => 'alert_type', :conditions => "timestamp > '#{time}' and timestamp < '#{time.tomorrow}' and alert_type = 'Fall'").length
      data[:panics] = Event.find(:all, :include => 'alert_type', :conditions => "timestamp > '#{time}' and timestamp < '#{time.tomorrow}' and alert_type = 'Panic'").length
      @periods[time] = data
      i += 1
    end
    
    render :layout => false
  end
end
