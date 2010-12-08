class ReportingController < ApplicationController
  before_filter :authenticate_admin_moderator_installer?
  include UtilityHelper
  
  def avg_skin_temps
    @users = User.find(:all)
    @users.each do |user|
      user_id = user.id
    sql_strap_fasteneds = "select timestamp from strap_fasteneds where user_id = #{user_id} Order By timestamp desc"
    sql_strap_removeds  = "select timestamp from strap_fasteneds where user_id = #{user_id} Order By timestamp desc"
    timestamps_sf = []
    rows_strap_fasteneds = SkinTemp.connection.select_all(sql_strap_fasteneds)
    rows_strap_fasteneds.collect do |row|
      timestamps_sf << row['timestamp']
    end
    timestamps_sr = []
    rows_strap_removeds = SkinTemp.connection.select_all(sql_strap_removeds)
    rows_strap_removeds.collect do |row|
      timestamps_sr << row['timestamp']
    end
    conditions = []
    timestamps_sf.each do |timestamp|
      timestamp = timestamp.to_date
      begin_time = 120.minutes.ago(timestamp)
      end_time = 120.minutes.from_now(timestamp)      
      conditions << "(NOT( timestamp > '#{timestamp.to_s}' AND timestamp < '#{end_time.to_s}')) "
    end
    timestamps_sr.each do |timestamp|
      timestamp = timestamp.to_date
      begin_time = 5.minutes.ago(timestamp)
      end_time = 5.minutes.from_now(timestamp)      
      conditions << "(NOT (timestamp > '#{begin_time.to_s}' AND timestamp < '#{timestamp.to_s}')) "
    end
    if !conditions.blank?
      sql = "select avg(skin_temp) as average from skin_temps where skin_temp >= 87 AND skin_temp <= 95 AND skin_temp <> -1 AND user_id = #{user_id} AND #{conditions.join(' AND ')}"
      rows = SkinTemp.connection.select_all(sql)
      average = nil
      rows.collect do |row|
        average = row['average']
      end
      user[:average_skin_temp] = average
    else
      user[:average_skin_temp] =  nil
    end
    end
  end
  
  # Wed Oct 13 02:42:47 IST 2010 requirement updated
  #   https://redmine.corp.halomonitor.com/issues/3516#note-11
  # 1.  Group drop down
  #   1. If multiple groups, default to All Groups\
  #   2. If only 1 group
  # 2. Show all users (including demo users)
  def users
    # this is not required anymore. User.all or @group.users work now
    # users = User.find(:all, :include => [:roles, :roles_users], :order => 'users.id')
    
    # # @roles = []
    # # rows = Role.connection.select_all("Select Distinct name from roles order by name asc")
    # # 
    # # rows.collect do |row|
    # #   @roles << row['name']
    # # end
    # @roles = Role.all(:select => "DISTINCT name", :order => "name ASC").collect(&:name)
    
    # if current_user.is_super_admin?
    #   @groups = Group.find(:all)
    # else
    #   @groups = current_user.group_memberships
    #   @group = @groups.first
    # end
    @groups = current_user.group_memberships
    # @group_name = ''
    # if params[:group_name].blank?
    #   group = @groups.first
    # else
    #   @group_name = params[:group_name]
    #   session[:group_name] = @group_name
    #   group = Group.find_by_name(@group_name)
    # end
    #
    # CHANGED: show all users when group_name search parameter is blank
    #   This feature is introduced now. Earlier the empty option did exist in group dropdown
    #   but that was not showing all users. maybe was broken feature
    # * when user is_not_super_admin, it cannot see "All groups" option, so we need to select the first one
    # Wed Oct 13 03:14:13 IST 2010
    #   We do not select the first available now. Just show "all groups"
    @group_name = params[:group_name] # (params[:group_name] || ((current_user.is_super_admin? || @groups.blank?) ? '' : @groups.first.name))
    #
    # @groups.first replaced with nil
    @group = (@group_name.blank? ? nil : Group.find_by_name(@group_name))
    
    # if @group
    #   us = []
    #   users.each do |user|
    #     us << user if user.group_memberships.include? @group
    #   end
    #   @users = User.paginate :page => params[:page],:include => [:roles, :roles_users],:conditions => ['users.id in (?)',us] ,:order   => 'users.id',:per_page => REPORTING_USERS_PER_PAGE
    # else
    #   @users = User.paginate :page    => params[:page],
    #   :include => [:roles, :roles_users],
    #   :order   => 'users.id',
    #   :per_page => REPORTING_USERS_PER_PAGE
    # end
    #
    # exclude demo users. https://redmine.corp.halomonitor.com/issues/3274
    # users only from current_user.group_memberships should be visible. https://redmine.corp.halomonitor.com/issues/3550
    #
    # # only these users are visible to current_user
    # _user_ids = (@group.blank? ? @groups.collect(&:user_ids) : @group.user_ids).flatten.compact.uniq
    # Sat Oct 23 03:21:54 IST 2010
    #   * show admins, halousers, subscribers and caregivers
    _groups = (@group.blank? ? @groups : [@group]) # fetch groups, or make the single group an array
    _halousers = _groups.collect(&:has_halousers).flatten.compact # fetch halousers for groups
    #   * fetch admins of groups, [subscirbers & caregivers] of halousers
    #   * keep everyone in a single array, not multi-level arrays
    #   * collect ID of these users and 
    @users = [ _groups.collect(&:has_admins), _halousers, _halousers.collect(&:has_subscribers), _halousers.collect(&:has_caregivers) ].flatten.compact
    #
    # Sat Oct 23 03:30:46 IST 2010 : save another query. we already have these objects loaded in memory
    # # fetch users based on collected ids
    # @users = User.all( :conditions => {:id => _user_ids }, :order => "id ASC")
    #
    # show non-demo users, unless "/all" given in URL
    @users = @users.reject {|e| e.demo_mode? } if params[:id].to_s != "all"
    # 
    #  Tue Dec  7 20:26:53 IST 2010, ramonrails
    #   * pagination has "order", no need to sort
    # # sort now
    # # WARNING: costly on time. we should implement a better business logic for faster results
    # #  Wed Nov 10 01:36:30 IST 2010, ramonrails
    # # https://redmine.corp.halomonitor.com/issues/3667
    # @users.sort! {|a,b| a.id <=> b.id }
    #
    # paginate the list of users
    @users = @users.uniq.paginate :page => params[:page], :per_page => REPORTING_USERS_PER_PAGE, :order => 'id'

    # @users.each do |user|
    #   if user
    #     @user_names[user.login] = user.id
    #   end
    # end
    #
    # CHANGED: ** do not use ** Hash[]. keeps giving error
    # # @user_names = Hash[ @users.collect(&:login).zip( @users.collect(&:id) )]
    #
    # CHANGED: shorthand below is causing "odd number of arguments for Hash"
    # # @user_names = (@users.blank? ? {} : Hash[ @users.collect {|user| [user.login, user.id] } ])
    #
    # Wed Oct 13 02:59:29 IST 2010 generates hash out of login => id of users
    @user_names = {}
    @users.each {|user| @user_names[user.login] = user.id } unless @users.blank?
  end

  # code lifted from "users" action
  # https://redmine.corp.halomonitor.com/issues/3571
  def user_stats
    @groups = (current_user.is_super_admin? ? Group.all(:order => "name") : current_user.group_memberships)
    @group_name = params[:group_name]
    @group = (@group_name.blank? ? nil : Group.find_by_name( params[:group_name] )) 
    # 
    #  Thu Dec  9 01:28:27 IST 2010, ramonrails
    #   * more variables that are required in view
    @halouser_ids = User.halousers.collect(&:id).flatten.compact.uniq
    @group_halouser_ids = @groups.collect(&:has_halousers).flatten.compact.uniq.collect(&:id)
  end
  
  def purge_data
  	if request.post?
  	  @user_begin_time = UtilityHelper.user_time_zone_to_utc(params[:user_begin_time])
  	  @user_end_time = UtilityHelper.user_time_zone_to_utc(params[:user_end_time])
  	  
  	  if Vital.delete_all(["user_id = ? and timestamp > ? and timestamp < ? ",params[:user_id],@user_begin_time,@user_end_time]) > 0
  	  	PurgedLog.create(:user_id => params[:user_id],:model => 'Vital',:from_date => @user_begin_time,:to_date => @user_end_time)
  	  end
  	  
  	  if SkinTemp.delete_all(["user_id = ? and timestamp > ? and timestamp < ? ",params[:user_id],@user_begin_time,@user_end_time]) > 0
  	    PurgedLog.create(:user_id => params[:user_id],:model => 'SkinTemp',:from_date => @user_begin_time,:to_date => @user_end_time)	
  	  end
  	  
  	  if Battery.delete_all(["user_id = ? and timestamp > ? and timestamp < ? ",params[:user_id],@user_begin_time,@user_end_time]) > 0
  	    PurgedLog.create(:user_id => params[:user_id],:model => 'Battery',:from_date => @user_begin_time,:to_date => @user_end_time)	
  	  end
  	  
  	  if  Step.delete_all(["user_id = ? and begin_timestamp > ? and end_timestamp < ? ",params[:user_id],@user_begin_time,@user_end_time]) > 0
  	    PurgedLog.create(:user_id => params[:user_id],:model => 'Step',:from_date => @user_begin_time,:to_date => @user_end_time)
  	  end
  	  
  	  redirect_to :controller => 'purged_logs',:action => 'index'
  	end
  end
  
  def user_hidden
    @user = User.find(params[:user_id], :include => [:roles, :roles_users])
    render :partial => 'user_hidden', :layout => false
  end
  
  def devices
    # FIXME: make a hash of conditions rather than SQL
    #   if we already search by ID / serial_number, why do we need to add device_id condition?
    @devices = []
    # conditions = ''
    if params[:query] and !params[:query].blank?
      conditions = (params[:query].size == 10 ? {:serial_number => params[:query].strip} : {:id => params[:query].to_i})
      # conditions = "id = #{params[:query]}" if params[:query].size < 10
      # conditions = "serial_number = '#{params[:query].strip}'" if params[:query].size == 10
    end
    if current_user.is_super_admin?
      @devices = Device.all(:conditions => conditions)
    else
      # we need this query here just for the LOGGER
      group_ids = current_user.is_admin_of_what.select {|e| e.is_a?(Group) }.collect(&:id)
      RAILS_DEFAULT_LOGGER.warn(group_ids.join(','))
      # groups = current_user.group_memberships
      # g_ids = []
      # groups.each do |group|
      #   g_ids << group.id if(current_user.is_admin_of?(group))
      # end
      # group_ids = g_ids.join(', ')
      # RAILS_DEFAULT_LOGGER.warn(group_ids)
      #
      # FIXME: why do we need embedde SQL here?
      # we can do same query in ruby (with very quick load times) like...
      #
      # 
      groups = current_user.is_admin_of_what.select {|e| e.is_a?(Group)}
      @devices += groups.collect(&:has_halouser).flatten.collect(&:devices).flatten.uniq
      @devices += groups.collect(&:has_admin).flatten.collect(&:devices).flatten.uniq
      # https://redmine.corp.halomonitor.com/issues/3103
      # anyone other than super admin was getting search results filtered
      ( [:serial_number, :id].each { |field| (@devices = @devices.select {|e| e.send("#{field}".to_sym) == conditions[field] }) if conditions.has_key?(field) } ) unless conditions.blank?
      @devices = @devices.uniq
      # @devices += current_user.is_admin_of_what.select {|e| e.is_a?(Group)}.collect(&:has_halouser).flatten.collect(&:devices).flatten.uniq
      #
      # conditions += " AND " unless conditions.blank? # https://redmine.corp.halomonitor.com/issues/2890
      # conditions += " devices.id IN (Select device_id from devices_users where devices_users.user_id IN (Select user_id from roles_users INNER JOIN roles ON roles_users.role_id = roles.id where roles.id IN (Select id from roles where authorizable_type = 'Group' AND authorizable_id IN (#{group_ids}))))"
    end
    # if conditions.blank?
    #   @devices = Device.find(:all, :order => "id asc")
    #else
    #  @devices = Device.find(:all, :order => "id asc",:conditions => conditions)
    #end
    @devices.sort! {|x,y| x.id <=> y.id }
    @devices = @devices.paginate :page => params[:page], :per_page => REORTING_DEVICES_PER_PAGE
    # @devices = Device.paginate :page => params[:page], :conditions => conditions, :order => "id asc", :per_page => REORTING_DEVICES_PER_PAGE
  end
  
  def device_hidden
    @device = Device.find(params[:device_id])
    render :partial => 'device_hidden', :layout => false
  end

  def sort_user_table
    # WARNING: Code coverage is zero for this code. Highly recommended to cover it.
    # this was already commented
    #
    # order = "#{params[:col]} asc"
    # users = User.find(:all, :order => order)

    # just create a hash of options here. search later a few lines below
    options = (params[:col] == 'name' ? {:include => :profile, :order => 'profiles.last_name'} : {:order => "users.id"})
    # if params[:col] == 'name'
    #   users = User.all(:include => :profile, :order => 'profiles.last_name')
    # else
    #   users = User.all(:order => :id) # params[:col]
    # end
    
    @group_name = params[:group_name]
    group = (@group_name.blank? ? nil : Group.find_by_name(@group_name)) # @groups.first replaced with nil
    # @group_name = ''
    # if !session[:group_name].blank?
    #   @group_name = session[:group_name]
    #   @group = Group.find_by_name(@group_name)
    # end
    # sortby = 'id'
    
    # * filter users that have some role for the selected group
    # * keep all users if group is blank
    # * options hash was created a few lines above, from the sort parameter passed
    @users = User.all(options).select {|user| user.has_role_for?(group) } unless group.blank?
    # * include profile, just in case we have to sort by name
    # * make :order option dynamic, subject to parameter received
    @users = @users.paginate :page => params[:page], :include => [:roles, :roles_users, :profile] ,:order => options[:order], :per_page => REPORTING_USERS_PER_PAGE
    # everything else should work as earlier
    
    render :partial => 'user_table', :locals => {:users => @users, :sortby => params[:col], :reverse => false}
  end
  
  def search_user_table
    @users = User.filtered( params[:query] )
    # @users = User.find(:all, :conditions => "login like '%#{params[:query]}%' or profiles.first_name like '%#{params[:query]}%' or profiles.last_name like '%#{params[:query]}%'",:include => [ :profile ])
    render :partial => 'user_table', :locals => {:users => @users, :sortby => 'id', :reverse => false}
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
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    if !@user_end_time.blank? && !@user_begin_time.blank?
      @end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
      @begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
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
    	Compliance.lost_data_scan(user_id)
  		if params[:begin_time]
  			@user_begin_time = params[:begin_time]
    		@user_end_time = params[:end_time]
    		@end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
      		@begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
    		
			@lost_data = LostData.paginate(:page => params[:page], :per_page => 50, :conditions => "user_id = #{user_id} and begin_time > '#{@begin_time}' and end_time < '#{@end_time}'", :order => "id desc")  		
  		else
    	    @lost_data = LostData.paginate(:page => params[:page], :per_page => 50, :conditions => "user_id = #{user_id}", :order => "id desc")
	 	end
    else
    	redirect_to '/'
    end 
    
  end
  def lost_data_daily
    
  end
  def remove_user_mapping
    user_id = params[:id]
    device_id = params[:device_id]
    # 
    # TODO: user ORM instead of SQL here
    #   device = Device.find_by_id( params[:device_id])
    #   device.users = [] # this will disconnect all users from this device
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
  
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    if !@user_end_time.blank? && !@user_begin_time.blank?
      #@end_time = @end_time.to_time
      #@begin_time = @begin_time.to_time
      @end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
      @begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
      @users, @total_lost_data, @total_not_worn = Compliance.compliance_halousers(@begin_time, @end_time)
    else
      flash[:warning] = 'Begin Time and End Time are required.'
      render :partial => 'init_strap_not_worn', :layout => true
    end    
  end
  
  def strap_not_worn_data
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    user_id = params[:id]
    @user = User.find(user_id)
    if params[:begin_time]
    	@end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
      	@begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
        @strap_not_worn = StrapNotWorn.paginate(:page => params[:page], :per_page => 50, :conditions => "user_id = #{user_id} and begin_time > '#{@begin_time}' and end_time < '#{@end_time}'", :order => "id desc") 
    else
    	@strap_not_worn = StrapNotWorn.paginate(:page => params[:page], :per_page => 50, :conditions => "user_id = #{user_id}", :order => "id desc")
    end
  end
  
  def init_successful_user_logins
    render :partial => 'init_successful_user_logins', :layout => true
  end
  def successful_user_logins
 
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    if !@user_end_time.blank? && !@user_begin_time.blank?
      #@end_time = @end_time.to_time
      #@begin_time = @begin_time.to_time
      @end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
      @begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
      @users = Compliance.successful_user_logins(@begin_time, @end_time)
    else
      flash[:warning] = 'Begin Time and End Time are required.'
      render :partial => 'init_successful_user_logins', :layout => true
    end
  end
  
  def audit
    @stream = params[:stream].to_i > 0 ? true : false
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    if current_user.is_super_admin?
      @groups = Group.find(:all)
    else
      @groups = current_user.group_memberships
	end
    if !@user_end_time.blank? && !@user_begin_time.blank?
    	@end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
    	@begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
		@group = Group.find_by_name(params[:group_name])
        @users = User.find(:all)
    	
    	owners = "0"
	  	@users.each do |user|
		  owners += "," + user.id.to_s if user.has_role? "halouser", @group
		  user.has_caregivers.each do |caregiver|
		  	owners += "," + caregiver.id.to_s
	      end
	  	end

        @audits = Audit.paginate(
          :page => params[:page],
          :per_page => 10,
          :conditions => ["created_at >= ? AND created_at <= ? and owner_id IN (#{owners})", @begin_time, @end_time], 
          :order => "owner_id ASC, created_at DESC"
         # :include => [:owner] :error => Can not eagerly load the polymorphic association :owner
          )
    else
      flash[:warning] = 'Begin Time and End Time are required.'
      render :action => :audit and return
    end
  end
  
  def fall_panic_report
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
    
    if !@user_end_time.blank? && !@user_begin_time.blank?
    	@end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
    	@begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)
    	
    	@falls = Event.find_all_by_event_type("Fall", :conditions => ["timestamp >= ? AND timestamp <= ?", @begin_time, @end_time])
    	@panics = Event.find_all_by_event_type("Panic", :conditions => ["timestamp >= ? AND timestamp <= ?", @begin_time, @end_time])
    	@gwalarm = Event.find_all_by_event_type("GwAlarmButton", :conditions => ["timestamp >= ? AND timestamp <= ?", @begin_time, @end_time])
    	
        @user_groups = {}
        @group_stats = {}
        @group_totals = {}
        #flash[:notice] = @falls[0].user.group_memberships.length            #is_halouser_for_what.length
      	#exit
      	#gather the stats in a 2 dimensional hash/array fall by fall
      	@group_totals[:false_alarm_falls] = 0
      	@group_totals[:test_alarm_falls] = 0
      	@group_totals[:real_falls] = 0
      	@group_totals[:real_alarm_falls] = 0
 		@group_totals[:unclassified_falls] = 0
 		@group_totals[:ems_falls] = 0
 		
      	@group_totals[:false_alarm_panics] = 0
      	@group_totals[:test_alarm_panics] = 0
      	@group_totals[:non_emerg_panics] = 0
      	@group_totals[:duplicate] = 0
      	@group_totals[:real_alarm_panics] = 0
      	@group_totals[:unclassified_panics] = 0
      	@group_totals[:ems_panics] = 0
      	@group_totals[:real_panics] = 0
      	@group_totals[:installs] = 0
		@group_totals[:battery_reminders] = 0
		@group_totals[:total] = 0
      	@group_totals[:total_response] = 0.0
      	@group_totals[:gwalarm] = 0
      	@group_totals[:gwreset_falls] = 0
      	@group_totals[:gwreset_panics] = 0
      	
      	for gwalarm in @gwalarm
      		id = gwalarm.user.id
      		if (groups = @user_groups[id]) == nil
    		  groups = @user_groups[id] = gwalarm.user.is_halouser_for_what
    		end
      		if(groups)
        	  groups.each do |group|
        	  	if !group.nil?
        	  	  if @group_stats[group.name].nil? 
         		    @group_stats[group.name] = {} 
         		  end
         		  if @group_stats[group.name][:gwalarm].nil? 
            	    @group_stats[group.name][:gwalarm] = [] 
            	  end
            	  @group_stats[group.name][:gwalarm] << gwalarm 
         		  @group_totals[:gwalarm] += 1 if group.name !="safety_care" and group.name !="halo"
    	  	    end
    	      end
	        end
  	    end
      	      	
      	for fall in @falls
      	  id = fall.user.id
      		if (groups = @user_groups[id]) == nil
    		    groups = @user_groups[id] = fall.user.is_halouser_for_what
    		  end
      		 if(groups)
        		 groups.each do |group|
        		   if !group.nil?
        		     if @group_stats[group.name].nil? 
         			   @group_stats[group.name] = {} 
         			 end
         			 if fall.call_center_response and not fall.test_alarm?
         			   @group_stats[group.name][:total_response] = 0.0 if !@group_stats[group.name][:total_response]
         			   @group_stats[group.name][:total] = 0 if !@group_stats[group.name][:total]
         			   @group_stats[group.name][:total_response] += fall.call_center_response.to_time - fall.timestamp.to_time
         			   @group_stats[group.name][:total] += 1
         			   @group_totals[:total] += 1
         			   @group_totals[:total_response] += fall.call_center_response.to_time - fall.timestamp.to_time
     			     end
          		     if fall.false_alarm?
            			   if @group_stats[group.name][:false_alarm_falls].nil? 
            			     @group_stats[group.name][:false_alarm_falls] = [] 
            			   end
            			   @group_stats[group.name][:false_alarm_falls] << fall
            			   @group_totals[:false_alarm_falls] += 1 if group.name !="safety_care" and group.name !="halo"
          		     elsif fall.test_alarm?
          		       if @group_stats[group.name][:test_alarm_falls].nil?
          		         @group_stats[group.name][:test_alarm_falls] = []
          		       end
          		       @group_stats[group.name][:test_alarm_falls] << fall
          		       @group_totals[:test_alarm_falls] += 1 if group.name !="safety_care" and group.name !="halo"
          		     elsif fall.real_alarm?
          		       if @group_stats[group.name][:real_alarm_falls].nil?
          		         @group_stats[group.name][:real_alarm_falls] = []
          		       end
          		       @group_stats[group.name][:real_alarm_falls] << fall
          		       @group_totals[:real_alarm_falls] += 1 if group.name !="safety_care" and group.name !="halo"
          		     elsif fall.gw_reset?
            	  	    if @group_stats[group.name][:gwreset_falls].nil?
          		          @group_stats[group.name][:gwreset_falls] = []
          		        end
          		        @group_stats[group.name][:gwreset_falls] << gwalarm
          		        @group_totals[:gwreset_falls] += 1 if group.name !="safety_care" and group.name !="halo"
                     elsif fall.ems?
            	  	    if @group_stats[group.name][:ems_falls].nil?
          		          @group_stats[group.name][:ems_falls] = []
          		        end
          		        @group_stats[group.name][:ems_falls] << fall
          		        @group_totals[:ems_falls] += 1 if group.name !="safety_care" and group.name !="halo"
        		     else
        		       if @group_stats[group.name][:unclassified_falls].nil?
        		         @group_stats[group.name][:unclassified_falls] = [] 
        		       end
          			   @group_stats[group.name][:unclassified_falls] << fall
          			   @group_totals[:unclassified_falls] += 1 if group.name !="safety_care" and group.name !="halo"
          		     end	
      		       end
  		         end
  		      end
      	  end

      	#gather the stats in a 2 dimensional hash/array fall by fall      	
      	for panic in @panics  	  
      		id = panic.user.id
      		if (groups = @user_groups[id]) == nil
    		    groups = @user_groups[id] = panic.user.is_halouser_for_what
    		end
      		if(groups)
        		groups.each do |group|  
        		  if !group.nil?  
        		    if @group_stats[group.name].nil? 
         			   @group_stats[group.name] = {} 
         			end
       			    if panic.call_center_response and not panic.test_alarm?
         	          @group_stats[group.name][:total_response] = 0.0 if !@group_stats[group.name][:total_response]
         	          @group_stats[group.name][:total] = 0 if !@group_stats[group.name][:total]
         	          @group_stats[group.name][:total_response] += panic.call_center_response.to_time - panic.timestamp.to_time
         	          @group_stats[group.name][:total] += 1
         	          @group_totals[:total] += 1
         	          @group_totals[:total_response] += panic.call_center_response.to_time - panic.timestamp.to_time
     		        end
            		if panic.false_alarm?
            		  if @group_stats[group.name][:false_alarm_panics].nil? 
            		    @group_stats[group.name][:false_alarm_panics] = [] 
            		  end
            		  @group_stats[group.name][:false_alarm_panics]  << panic
            		  @group_totals[:false_alarm_panics] += 1 if group.name !="safety_care" and group.name !="halo"
            		elsif panic.test_alarm?
            		  if @group_stats[group.name][:test_alarm_panics].nil?
            		    @group_stats[group.name][:test_alarm_panics] = []
            		  end
            		  @group_stats[group.name][:test_alarm_panics]  << panic
            		  @group_totals[:test_alarm_panics] += 1 if group.name !="safety_care" and group.name !="halo"
            		elsif panic.non_emerg_panic?
            		  if @group_stats[group.name][:non_emerg_panics].nil?
            		    @group_stats[group.name][:non_emerg_panics] = []
            		  end 
            		  @group_stats[group.name][:non_emerg_panics]  << panic
            		  @group_totals[:non_emerg_panics] += 1 if group.name !="safety_care" and group.name !="halo"
                    elsif panic.duplicate?
            		  if @group_stats[group.name][:duplicate].nil?
            		    @group_stats[group.name][:duplicate] = []
            		  end 
            		  @group_stats[group.name][:duplicate]  << panic
            		  @group_totals[:duplicate] += 1 if group.name !="safety_care" and group.name !="halo"
            		elsif panic.real_alarm?
            		  if @group_stats[group.name][:real_alarm_panics].nil?
            		    @group_stats[group.name][:real_alarm_panics] = []
            		  end
            		  @group_stats[group.name][:real_alarm_panics]  << panic
            		  @group_totals[:real_alarm_panics] += 1 if group.name !="safety_care" and group.name !="halo"
          		    elsif panic.gw_reset?
            	  	  if @group_stats[group.name][:gwreset_panics].nil?
          		        @group_stats[group.name][:gwreset_panics] = []
          		      end
          		      @group_stats[group.name][:gwreset_panics] << gwalarm
          		      @group_totals[:gwreset_panics] += 1 if group.name !="safety_care" and group.name !="halo"
                    elsif fall.ems?
            	  	  if @group_stats[group.name][:ems_panics].nil?
          		        @group_stats[group.name][:ems_panics] = []
          		      end
          		      @group_stats[group.name][:ems_panics] << panic
          		      @group_totals[:ems_panics] += 1 if group.name !="safety_care" and group.name !="halo"
          			else
          		  	  if @group_stats[group.name][:unclassified_panics].nil?
            		    @group_stats[group.name][:unclassified_panics] = []
            		  end
            		  @group_stats[group.name][:unclassified_panics]  << panic
            		  @group_totals[:unclassified_panics] += 1 if group.name !="safety_care" and group.name !="halo"
            		end
          	  	  end
      		    end
        	end	
      	end
      	
        get_installs
        
        get_battery_reminders
    end
  	#flash[:warning] = 'Begin Time and End Time are required.'
  end
  
  def get_installs
    @installs = SelfTestSession.find(:all,
  								     :select => "user_id,count(*)",
  	                                 :conditions => ["completed_on >= ? AND completed_on <= ?", @begin_time.to_s(:db), @end_time.to_s(:db)],
  	                                 :group => 'user_id')
  	 for install in @installs
  	 	id = install.user.id
  		if (groups = @user_groups[id]) == nil
		    groups = @user_groups[id] = install.user.is_halouser_for_what
		  end
		  if(groups)
      		groups.each do |group|
      			if !group.nil?
      			  if @group_stats[group.name].nil? 
       			   @group_stats[group.name] = {} 
       			  end
       			  
      			  if @group_stats[group.name][:installs].nil?
        		    @group_stats[group.name][:installs] = []
        		  end
      			  @group_stats[group.name][:installs]  << install
      			  @group_totals[:installs] += 1 if group.name !="safety_care" and group.name !="halo"
  			    end
  			end
		  end
  	 end
  end
  
  def get_battery_reminders
  	@battery_reminders = BatteryReminder.find(:all,:conditions => ["reminder_num >= ?",3])
  	for battery_reminder in @battery_reminders
  		id = battery_reminder.user.id
  		if (groups = @user_groups[id]) == nil
		    groups = @user_groups[id] = battery_reminder.user.is_halouser_for_what
		end
		if(groups)
      		groups.each do |group|
      			if !group.nil?
      			  if @group_stats[group.name].nil? 
       			   @group_stats[group.name] = {} 
       			  end
       			  
      			  if @group_stats[group.name][:battery_reminders].nil?
        		    @group_stats[group.name][:battery_reminders] = []
        		  end
      			  @group_stats[group.name][:battery_reminders]  << battery_reminder
      			  @group_totals[:battery_reminders] += 1 if group.name !="safety_care" and group.name !="halo"
  			    end
  			end
		end
  	end
  end
  
  def installs
    @begin_date = params[:begin_date]
    @end_date = params[:end_date]
    get_installs 
  end
  
  def compliance_report
    @user_begin_time = params[:begin_time]
    @user_end_time = params[:end_time]
  	if current_user.is_super_admin?
  	  @groups = Group.find(:all)
  	else
      @groups = current_user.group_memberships
    end
    if !@user_end_time.blank? && !@user_begin_time.blank?
		
    	@end_time = UtilityHelper.user_time_zone_to_utc(@user_end_time)
    	@begin_time = UtilityHelper.user_time_zone_to_utc(@user_begin_time)

        #emacs
	if(!params[:id])  
    	  @group = Group.find_by_name(params[:group_name])
    	  @users = User.find(:all)
	end
    end
    #flash[:warning] = 'Begin Time and End Time are required.'
  end
  
end