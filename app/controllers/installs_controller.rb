class InstallsController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::TagHelper
  include RedboxHelper
  
  def stop_wizard
    init_devices_user
    launcher = new_remote_redbox('install_wizard_complete')
    render(:update) do |page|
      page.replace_html 'install_wizard_launch', launcher
    end
  end
  
  def session_report
  	@user = User.find(params[:id])
  end
  
  def ie6
    
  end
  
  def activate_user
    @user = User.find(params[:user_id])
    
      log = AccessLog.new
      log.user_id = current_user.id
      log.status = 'logout'
      log.save

      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
    redirect_to :controller => 'activate', :action => @user.activation_code
  end
  def index
    @groups = []
    if current_user.is_super_admin?
      @groups = Group.find(:all)	
    else
      gs = current_user.group_memberships
      gs.each do |g| 
        @groups << g if(current_user.is_installer_of?(g) || current_user.is_admin_of?(g))
      end
    end
    if @groups and @groups.length == 1
    	redirect_to :action => 'index_users',:group => @groups[0].name
    end
  end
  
  def index_users
    if check_params_for_group
      redirect_to :action => 'users', :controller => 'installs', :group => params[:group]
    else
      redirect_to :controller => 'installs', :action => 'index'
    end
  end
  
  def users
  	 @groups = []
    if current_user.is_super_admin?
      @groups = Group.find(:all)	
    else
      gs = current_user.group_memberships
      gs.each do |g| 
        @groups << g if(current_user.is_installer_of?(g) || current_user.is_admin_of?(g))
      end
    end
    if check_params_for_group
      @group = Group.find_by_name(params[:group])
      conds = "name = 'halouser' AND authorizable_type = 'Group' AND authorizable_id = #{@group.id}"
      @role = Role.find(:first, :conditions => conds)
      
      if params[:display] == 'not_completed'
      	@users = User.find(:all,:include => [:roles_users],:conditions  => "roles_users.role_id = #{@role.id}",:order => "users.id asc")
      	@all_users = []
      	for user in @users
      	install_session = user.self_test_sessions.find(:first,:conditions => "completed_on is not NULL", :order => 'completed_on desc')
      	@all_users << install_session.user_id if install_session
  		end
  		@users = User.paginate(:page => params[:page],:include => [:roles_users],:per_page => 10,:conditions => ["roles_users.role_id = #{@role.id} and users.id not in (?)",@all_users],:order => "users.id asc")
  	  elsif params[:display] == 'completed'
  	  	@users = User.paginate(:page    => params[:page],:include  => [:roles_users,:self_test_sessions],  :conditions  => "roles_users.role_id = #{@role.id}",:order => "self_test_sessions.completed_on desc",:per_page => 10)
  	  elsif !@role.nil?
      				@users = User.paginate(:page    => params[:page],
                                           :include     => [:roles_users,:self_test_sessions], 
                 #                         :conditions  => "users.id NOT IN (SELECT devices_users.user_id from devices_users) AND roles_users.role_id = #{@role.id}",
                                           :conditions  => "roles_users.role_id = #{@role.id}",
                                           :order       => "users.id asc",
                                           :per_page    => 10)
	  end
    else 
      redirect_to :controller => 'installs', :action => 'index'
    end
  end
  def registration
    clear_session_data
#    if session[:flash_prompt] == 0
#      session[:flash_prompt] = 1
#    elsif session[:flash_prompt] != 1
#      session[:flash_prompt] = 0
#    end
    if check_params_for_group
      @group = Group.find_by_name(params[:group])
      if !params[:id].blank?
        @id = params[:id]
        @user = User.find(@id)
        @gateway = Device.new
        @strap = Device.new
        
    @self_test_session = SelfTestSession.create(:created_at => Time.now, :user_id => @user.id, :created_by => current_user.id)
    @self_test_session_id = @self_test_session.id
      else
        redirect_to :controller => 'installs', :action => 'users'
      end
    else 
      redirect_to :controller => 'installs', :action => 'index'
    end
  end
  
  def registration_create
    @user = User.find(params[:user_id])
    @gateway = nil
    @strap = nil
    @self_test_session_id = params[:self_test_session_id]
    @self_test_session = SelfTestSession.find(@self_test_session_id)
    gateway_serial_number = params[:gateway_serial_number]
    unless gateway_serial_number
      gateway_serial_number = params[:gateway][:serial_number]      
    end
    #check if gateway exists
    if !gateway_serial_number.blank?
      if gateway_serial_number.size == 7
        gateway_serial_number = gateway_serial_number[0,2] + "000" + gateway_serial_number[2, 5] 
      end
      @gateway = Device.find_by_serial_number(gateway_serial_number)
      unless @gateway
        @gateway = @user.devices.build(params[:gateway])
      end
      begin
        @gateway.set_gateway_type
        @gateway.save!
      rescue Exception => e
        flash[:warning] = "#{e}"
        throw e
      end
    else
      msg = "Gateway Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
    
    #check is strap exists and if it is assigned to a user or not
    #could have been registered without assigning a user
    strap_serial_number = params[:strap_serial_number]
    unless strap_serial_number
      strap_serial_number = params[:strap][:serial_number]
    end
    if !strap_serial_number.blank?
      if strap_serial_number.size == 7
        strap_serial_number = strap_serial_number[0,2] + "000" + strap_serial_number[2, 5] 
      end
      @strap = Device.find_by_serial_number(strap_serial_number)
      if @strap && !@strap.users.blank? && !@strap.users.include?(@user)
        flash[:warning] = "Chest Strap/Belt Clip with Serial Number #{strap_serial_number} is already assigned to a user."
        @remove_link = true
        throw Exception.new
      end
      unless @strap
        @strap = @user.devices.build(params[:strap]) 
      end
      begin
        @strap.set_chest_strap_type
        @strap.save!
      rescue Exception => e
        flash[:warning] = "#{e}"
        throw e
      end
    else
      msg = "Chest Strap/Belt Clip Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
    if(@gateway.users.blank? || (!@gateway.users.blank? && !@gateway.users.include?(@user)))
       @gateway.users << @user
       @gateway.save!
    end
    if(@strap.users.blank?)
       @strap.users << @user
       @strap.save!
    end
    # @user.save!
    create_self_test_step(INSTALLATION_SERIAL_NUMBERS_ENTERED_ID) 
    session[:self_test_time_created] = Time.now
    redirect_to :action => 'install_wizard', :controller => 'installs', :self_test_session_id => @self_test_session_id,
    :gateway_id => @gateway.id, :strap_id => @strap.id, :user_id => @user.id
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR registering devices, #{e}")
    create_self_test_step(INSTALLATION_SERIAL_NUMBERS_ENTERED_FAILED_ID)
    render :action => 'registration'
  end
  
  def remove_user_mapping
    user_id = params[:user_id]
    device_id = params[:device_id]
    Device.connection.delete "delete from devices_users where device_id = #{device_id}"
    redirect_to :action => 'registration_create', :controller => 'installs', 
                  :user_id => user_id,  :self_test_session_id => params[:self_test_session_id],
                  :gateway_serial_number => params[:gateway_serial_number], :strap_serial_number => params[:strap_serial_number]
  end
  
  def install_wizard
    init_devices_user
    create_mgmt_cmd('self_test', @gateway.id)
    #   create_self_test_step(SELF_TEST_CHEST_STRAP_MGMT_COMMAND_CREATED_ID)
    #    create_mgmt_cmd('self_test', @strap.id)
    
    create_self_test_step(SELF_TEST_PHONE_MGMT_COMMAND_CREATED_ID)
    create_mgmt_cmd('self_test_phone', @gateway.id)
    session[:progress_count]= {}
  end
  
  def restart_install_wizard
    init_devices_user
    clear_session_data
    @self_test_session = SelfTestSession.create(:created_at => Time.now, :user_id => @user.id, :created_by => current_user.id)
    @self_test_session_id = @self_test_session.id
    session[:self_test_time_created] = Time.now
    redirect_to :action => 'install_wizard', :controller => 'installs', :self_test_session_id => @self_test_session_id,
    :gateway_id => @gateway.id, :strap_id => @strap.id, :user_id => @user.id
  end
  def flash_prompt_start
    
  end
  def phone_prompt_init
    @user = User.find(params[:user_id])
    render(:update) do |page|
      phone_launch = launch_remote_redbox(:url =>  {  :action => 'phone_prompt_start', :controller => 'installs', 
                                     :user_id => @user.id }, 
                         :html => { :method => :get, :complete => '' } ) 
      page['phone_launcher'].replace_html phone_launch
    end
  end  
  def phone_prompt_start

  end
  
  def ethernet_prompt_init
    @user = User.find(params[:user_id])
    render(:update) do |page|
      phone_launch = launch_remote_redbox(:url =>  {  :action => 'ethernet_prompt_start', :controller => 'installs', 
                                     :user_id => @user.id }, 
                         :html => { :method => :get, :complete => '' } ) 
      page['phone_launcher'].replace_html phone_launch
    end
  end  
  def ethernet_prompt_start

  end
  
  def led_prompt_init
    @user = User.find(params[:user_id])
    render(:update) do |page|
      phone_launch = launch_remote_redbox(:url =>  {  :action => 'led_prompt_start', :controller => 'installs', 
                                     :user_id => @user.id }, 
                         :html => { :method => :get, :complete => '' } ) 
      page['phone_launcher'].replace_html phone_launch
    end
  end
  def led_prompt_start
    
  end
  
  def flash_install_upgrade
    
  end
  
  def failure_notice
    init_devices_user
    @failure_notice = params[:message]
    @self_test_step_id = params[:self_test_step_id]
    @self_test_result_id = params[:self_test_result_id]
    @self_test_result = SelfTestResult.find(@self_test_result_id) if !@self_test_result_id.blank?
    #clear_session_data
  end
  
  def install_wizard_strap_fastened_progress
    init_devices_user
    message = 'Detecting Strap Fastened'
    battery_msg = check_battery_critical?
    if !check_battery_critical?
      self_test_step = check_strap_fastened()
      if self_test_step
        session[:progress_count][:strap_fastened] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_CHEST_STRAP_COMPLETE_ID}")
        message = self_test_step.self_test_step_description.description
        render_update_success('strap_fastened_div_id', message, 'updateCheckStrapFastened', 'updateCheckHeartrate', 
                              'strap_fastened_check', 'update_percentage', CHEST_STRAP_DETECTED_PERCENTAGE, self_test_step.timestamp - previous_step.timestamp)
      elsif check_strap_fastened_timeout?
        session[:progress_count][:strap_fastened] = nil
        step = create_self_test_step(CHEST_STRAP_FASTENED_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Strap Fastened Detection timed out.  To reset your chest strap/belt clip please plug it in and hold panic button for 7 seconds.  Please put on the chest strap/belt clip and rerun the Installation Wizard."
        clear_session_data
        render_update_timeout('strap_fastened_div_id', message, 'updateCheckStrapFastened', 'install_wizard_launch')
      else
        render_update_message('strap_fastened_div_id', message, :strap_fastened)
      end
    else
      render_update_battery_critical('battery_critical_div_id', battery_msg, 'updateCheckStrapFastened')
    end
  end
    
  def phone_test_complete
    init_devices_user
    @battery = Battery.find(:first, :conditions => "device_id = #{@strap.id} AND timestamp >= '#{@self_test_session.created_at.to_s}'", :order => 'timestamp desc')  
  end
  def no_phone_test
    init_devices_user
 #   @battery = Battery.find(:first, :conditions => "device_id = #{@strap.id} AND timestamp >= '#{@self_test_session.created_at.to_s}'", :order => 'timestamp desc')  
  launcher = new_remote_redbox('phone_test_complete')
    render(:update) do |page|
      page.replace_html 'install_wizard_launch', launcher
    end
  end
  def start_range_test_only_init
    @user = User.find(params[:id])
    render(:update) do |page|
      page.replace_html 'range_test_launcher', launch_remote_redbox(:url =>  {  :action => 'range_test_only', 
                                  :controller => 'installs',  :user_id => @user.id,
                                  }, :html => { :method => :get, :complete => '' } )
    end
  end
  def range_test_only
    @user = User.find(params[:user_id])
    strap = @user.chest_strap
    if strap
      @battery = Battery.find(:first, :conditions => "device_id = #{strap.id}", :order => 'timestamp desc')  
    end
  end
  def start_range_test_only
    @user = User.find(params[:user_id])
    strap = @user.chest_strap
    if strap
      create_mgmt_cmd('range_test_start', strap.id)
    end
    render(:update) do |page|
      page.replace_html 'range_test_launcher', launch_remote_redbox(:url =>  {  :action => 'stop_range_test_only_init', 
                                  :controller => 'installs',  :user_id => @user.id,
                                  }, :html => { :method => :get, :complete => '' } )
    end
  end
  def stop_range_test_only_init
    @user = User.find(params[:user_id])
  end
  def stop_range_test_only
    @user = User.find(params[:user_id])
    strap = @user.chest_strap
    if strap
      create_mgmt_cmd('range_test_stop', strap.id)
    end
    render(:update) do |page|
      page.replace_html 'range_test_launcher', launch_remote_redbox(:url =>  {  :action => 'installation_notes', 
                                  :controller => 'installs',  :user_id => @user.id,
                                  }, :html => { :method => :get, :complete => '' } )
    end
  end
  
  def installation_notes
    @user = User.find(params[:user_id])
    @notes = InstallationNote.new(:user_id => @user.id)
  end
  def submit_installation_notes
    @user = User.find(params[:user_id])
    @note = InstallationNote.new(:user_id => @user.id, :notes => params[:notes])
    @note.save!
    render :text => ''
  end
  def start_range_test
    init_devices_user
      launcher = new_remote_redbox('range_test')
    create_self_test_step(START_RANGE_TEST_PROMPT_ID)
    create_mgmt_cmd('range_test_start', @strap.id)
    render(:update) do |page|
      page.replace_html 'range_test_start_div', launcher
    end
  end
  
  def range_test
    init_devices_user
  end
  
  def stop_range_test
    init_devices_user
    create_mgmt_cmd('range_test_stop', @strap.id)
    self_test_step = create_self_test_step(RANGE_TEST_COMPLETE_ID)
      previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{HEARTRATE_DETECTED_ID}")
      message = self_test_step.self_test_step_description.description                       
    duration = nil
    unless previous_step
      previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{HEARTRATE_DETECTED_ID}")
    end
    duration = self_test_step.timestamp - previous_step.timestamp
    create_mgmt_cmd('mgmt_poll_rate', @gateway.id, MGMT_POLL_RATE)
    create_self_test_step(SLOW_POLLING_MGMT_COMMAND_CREATED_ID)
    
    # render_update_success('range_test_div_id', message, nil, nil, 
    #                           'range_test_check', 'update_percentage', RANGE_TEST_PERCENTAGE, 
    #                           duration, 'notes', 'install_wizard_launch')
                          
    save_notes(@self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{RANGE_TEST_COMPLETE_ID}").id)
    launcher = new_remote_redbox('add_caregiver')
    render(:update) do |page|
      page.call('update_percentage', RANGE_TEST_PERCENTAGE)
      page.replace_html 'install_wizard_launch', launcher
    end
  end

  def notes
    init_devices_user
  end
  
  def submit_range_test_notes
    init_devices_user
    
    save_notes(@self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{RANGE_TEST_COMPLETE_ID}").id)
    #launcher = new_remote_redbox('install_wizard_complete')
    launcher = new_remote_redbox('add_caregiver')
    render(:update) do |page|
      page.replace_html 'install_wizard_launch', launcher
    end
    
  end
  
  def submit_notes
    init_devices_user
    save_notes(params[:self_test_step_id])
    render :nothing => true
  end
  
  def battery_critical
    init_devices_user
    clear_session_data
  end
  def install_wizard_complete
    init_devices_user
    @self_test_session.completed_on = Time.now
    @self_test_session.save!
    clear_session_data
    session[:self_test_time_created] = Time.now
  end

  def resend
    # 
    #  Tue Nov 23 22:51:54 IST 2010, ramonrails
    #   * DEPRECATED: https://spreadsheets0.google.com/ccc?key=tCpmolOCVZKNceh1WmnrjMg&hl=en#gid=4
    # 
    #  Fri Dec 10 20:53:49 IST 2010, ramonrails
    #   * re-activated on https://redmine.corp.halomonitor.com/issues/3857
    #
    if (@user = User.find params[:id])
      if @user.email.blank?
        flash[:notice] = "User #{@user} does not have an email."
      else
        #   * Keep DRY. user model has business logic to dispatch emails.
        if @user.dispatch_emails( :force => true) # forced
          flash[:notice] = "Signup/Installation email resent to #{@user.email}"
        else
          flash[:notice] = "Signup/Installation email was not send again to #{@user.email}"
        end
      end
    else
      flash[:notice] = "User not found. Please check with customer support"
    end
    # user = User.find params[:id]
    # #UserMailer.deliver_activation(user) if user.recently_activated?
    # UserMailer.deliver_signup_installation(user,user)
    # flash[:notice] = "Signup/Installation email resent to #{user.email}"
    # #redirect_to (request.env['HTTP_REFERER'])
  end
  
  
  private
  
  def init_devices_user
    @gateway_id = params[:gateway_id]
    @strap_id = params[:strap_id]
    @user = User.find(params[:user_id])
    @gateway = Device.find(@gateway_id)
    @strap = Device.find(@strap_id)
    @self_test_session_id = params[:self_test_session_id]
    @self_test_session = SelfTestSession.find(@self_test_session_id)
  end
  
  def check_phone_self_test()
    delay = @self_test_session.created_at
    #    if(!session[:halo_check_phone_self_test])
    conds = "device_id = #{@gateway_id} AND cmd_type = 'self_test_phone' AND result = true AND timestamp > '#{delay.to_s}'"
    @self_test = SelfTestResult.find(:first, :conditions => conds)
    if @self_test    
      self_test_step = create_self_test_step(SELF_TEST_PHONE_COMPLETE_ID)
      session[:halo_check_phone_self_test] = self_test_step
      session[:halo_check_phone_self_test_result] = @self_test
      return self_test_step
    else
      conds = "device_id = #{@gateway_id} AND cmd_type = 'self_test_phone' AND result = false AND timestamp > '#{delay.to_s}'"
      @self_test = SelfTestResult.find(:first, :conditions => conds)        
      session[:halo_check_phone_self_test_result] = @self_test
      return false
    end
    #    else
    #      return session[:halo_check_phone_self_test]
    #    end
  end
  
  def check_chest_strap_self_test()
    #    delay = @self_test_session.created_at
    #    if(!session[:halo_check_chest_strap_self_test])
    #      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{strap_id} AND cmd_type = 'self_test' AND result = true AND timestamp > '#{delay.to_s}'")
    #      if @self_test  
    #        self_test_step = create_self_test_step(SELF_TEST_CHEST_STRAP_COMPLETE_ID)
    #        session[:halo_check_chest_strap_self_test] = self_test_step
    #        return self_test_step
    #      else
    #        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{strap_id} AND cmd_type = 'self_test' AND result = false AND timestamp > '#{delay.to_s}'")
    #        return false
    #      end
    #    else
    #      return session[:halo_check_chest_strap_self_test]
    #    end
    @self_test = SelfTestResult.new(:result => true, 
                                    :cmd_type => 'self_test', 
    :device_id => @strap_id, 
    :timestamp => Time.now)   
    self_test_step = create_self_test_step(SELF_TEST_CHEST_STRAP_COMPLETE_ID)
    session[:halo_check_chest_strap_self_test] = self_test_step
    session[:halo_check_chest_strap_self_test_result] = @self_test
    return self_test_step
  end
  
  def check_gateway_self_test()
    delay = @self_test_session.created_at
    if(!session[:halo_check_gateway_self_test])
      conds = "device_id = #{@gateway_id} AND cmd_type = 'self_test' AND result = true AND timestamp > '#{delay.to_s}'"
      @self_test = SelfTestResult.find(:first, :conditions => conds)
      if @self_test   
        self_test_step = create_self_test_step(SELF_TEST_GATEWAY_COMPLETE_ID)
        session[:halo_check_gateway_self_test] = self_test_step
        session[:halo_check_gateway_self_test_result] = @self_test
        return self_test_step
      else
        conds = "device_id = #{@gateway_id} AND cmd_type = 'self_test' AND result = false AND timestamp > '#{delay.to_s}'"
        @self_test = SelfTestResult.find(:first, :conditions => conds)
        session[:halo_check_gateway_self_test_result] = @self_test
        return false
      end
    else
      return session[:halo_check_gateway_self_test]
    end
  end
  
  def check_registered()
    if(!session[:halo_check_registered])
      conds = "device_id = #{@strap_id} AND user_id = #{@user.id} AND cmd_type = 'user_registration'"
      user_registration_mgmt_cmd_strap   =  MgmtCmd.find(:first, :conditions => conds)
      
      if(user_registration_mgmt_cmd_strap && @user.devices.find(@gateway_id) && @user.devices.find(@strap_id))   
        self_test_step = create_self_test_step(REGISTRATION_COMPLETE_ID)
        session[:halo_check_registered] = self_test_step
        return self_test_step
      else
        return false
      end
    else
      return session[:halo_check_registered]
    end
  end
  
  def create_mgmt_cmd(type, device_id, param1=nil)
    MgmtCmd.create(:cmd_type            => type, 
                   :device_id           => device_id, 
                   :user_id             => @user.id,
                   :creator             => current_user,
                   :originator          => 'server',
                   :pending             => true,
                   :pending_on_ack      => true,                     
                   :timestamp_initiated => Time.now,
                   :param1              => param1)
  end
  
  def create_self_test_step(description_id)
    self_test_step_description = SelfTestStepDescription.find(description_id)    
    self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                                         :timestamp => Time.now,
                                         :user_id => current_user.id, 
                                         :halo_user_id => @user.id,
                                         :self_test_session_id => @self_test_session_id)
    return self_test_step
  end
  def check_params_for_group
    return (!params[:group].blank? && params[:group] != 'Choose a Group')
  end
  
  def check_strap_fastened
    delay = @self_test_session.created_at
    conds = "user_id = #{@user.id} AND device_id = #{@strap_id} AND timestamp > '#{delay.to_s}'"
    @strap_fastened = StrapFastened.find(:first, :conditions => conds)
    if @strap_fastened
      return create_self_test_step(CHEST_STRAP_FASTENED_DETECTED_ID)
    else
      return false
    end
    
  end
  
  def check_heartrate
    step = @self_test_session.self_test_steps.find(:first,:conditions => "self_test_step_description_id = #{SELF_TEST_CHEST_STRAP_COMPLETE_ID}")
    delay = step.timestamp
    conds = "user_id = #{@user.id} AND heartrate != -1 AND timestamp > '#{delay.to_s}'"
    @vital = Vital.find(:first, :conditions => conds)
    if @vital    
      create_self_test_step(HEARTRATE_DETECTED_ID)
    else
      return false
    end
  end
  def timeout?(self_test_step_description_id, seconds)
    step = @self_test_session.self_test_steps.find(:first,:conditions => "self_test_step_description_id = #{self_test_step_description_id}")
    if Time.now > (step.timestamp + seconds)
      return true
    else
      return false
    end
  end
  def check_heartrate_timeout?
   if previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_PHONE_COMPLETE_ID}")
      timeout?(SELF_TEST_PHONE_COMPLETE_ID, 240.seconds)
    elsif previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_PHONE_FAILED_ID}")
      timeout?(SELF_TEST_PHONE_FAILED_ID, 240.seconds)
    else
      timeout?(SELF_TEST_PHONE_TIMEOUT_ID, 240.seconds)
    end
  end
  HEARTRATE_DETECTED_ID
  def check_registration_timeout?
    if Time.now > (session[:self_test_time_created] + 180.seconds)
      return true
    else 
      return false
    end
  end
  
  def check_gateway_timeout?
    timeout?(REGISTRATION_COMPLETE_ID, 220.seconds)
  end
  
  def check_phone_timeout?
    timeout?(SELF_TEST_CHEST_STRAP_COMPLETE_ID, 145.seconds)
  end
  def check_chest_strap_timeout?
    timeout?(SELF_TEST_GATEWAY_COMPLETE_ID, 240.seconds)
  end
  
  def check_strap_fastened_timeout?
    timeout?(SELF_TEST_CHEST_STRAP_COMPLETE_ID, 240.seconds)
  end
  def progress_count(sym)
    if session[:progress_count][sym]
      session[:progress_count][sym] += 1
    else 
      session[:progress_count][sym] = 1
    end
    if session[:progress_count][sym] > 30
      session[:progress_count][sym] = 1
    end
    return session[:progress_count][sym]
  end
  
  def check_battery_critical?
    battery = Battery.find(:first, :conditions => "device_id = #{@strap.id} AND timestamp >= '#{@self_test_session.created_at.to_s}'", :order => 'timestamp desc')  
    if battery && battery.percentage <= 1
      return "Battery is at or less than 1% please recharge the battery."
    else
      return false
    end    
  end
  
  def render_update_battery_critical(message_id, message, false_id)
    launcher = new_remote_redbox('battery_critical', 'installs', message)
    launch_id = 'install_wizard_launch'
    render(:update) do |page|
      if false_id
        page.call(false_id, false)
      end
      page.replace_html launch_id, launcher
    end
    
  end
  def render_update_success(message_id, message, false_id, true_id, image_id, update_percentage_id, percentage, seconds, action=nil, launch_id=nil )
    launcher = new_remote_redbox(action, 'installs', message)
    render(:update) do |page|
      if false_id
        page.call(false_id, false)
      end
      page[image_id].src = "/images/checkbox.png"
      page.call(update_percentage_id, percentage)
      page.replace_html message_id, message
      page.replace_html message_id + '_duration', UtilityHelper.seconds_format(seconds)
      if true_id
        page.call(true_id, true)
      end
      if action && launch_id
        page.replace_html launch_id, launcher
      end
    end
  end
  
  def render_update_timeout(message_id, message, false_id, launch_id)
    if @self_test
      redbox = new_remote_redbox('failure_notice', 'installs', message, @self_test_step_id, @self_test.id)
    else
      redbox = new_remote_redbox('failure_notice', 'installs', message, @self_test_step_id)
    end
    render(:update) do |page|
      page.call(false_id, false)
      page.replace_html message_id, message
      page.replace_html launch_id, redbox
    end
  end
  
  def render_update_failure(message_id, message, false_id, launch_id)
    if @self_test
      redbox = new_remote_redbox('failure_notice', 'installs', message, @self_test_step_id, @self_test.id)
    else
      redbox = new_remote_redbox('failure_notice', 'installs', message, @self_test_step_id)
    end
    render(:update) do |page|
      page.call(false_id, false)
      page.replace_html message_id, message
      page.replace_html launch_id, redbox     
    end
  end
  
  def render_update_message(message_id, message, sym)
    count = progress_count(sym)
    dots = ''
    render(:update) do |page|
     (0..count).each do |i|
        dots += '.'
      end
      page.replace_html message_id, message
      page.replace_html message_id + '_duration', dots
    end
  end
  
  def new_remote_redbox(action, controller='installs', message=nil, self_test_step_id=nil, self_test_result_id=nil)
    launch_remote_redbox(:url =>  {  :action => action, :controller => controller, :message => message, 
                                     :self_test_session_id => @self_test_session_id, :user_id => @user.id,
                                     :gateway_id => @gateway_id, :strap_id => @strap_id, 
                                     :self_test_step_id => self_test_step_id, :self_test_result_id => self_test_result_id
                                  }, 
                         :html => { :method => :get, :complete => '' } )
  end
  def clear_session_data
    session[:self_test_time_created] = nil
    session[:progress_count] = nil
    session[:halo_check_phone_self_test] = nil
    session[:halo_check_phone_self_test_result] = nil
    session[:halo_check_chest_strap_self_test] = nil
    session[:halo_check_chest_strap_self_test_result] = nil
    session[:halo_check_gateway_self_test] = nil
    session[:halo_check_gateway_self_test_result] = nil
    session[:halo_check_registered] = nil
  end
  
  def save_notes(step_id)
    self_test_step = SelfTestStep.find(step_id)
    self_test_step.notes = params[:notes]
    self_test_step.save!
  end
  
end