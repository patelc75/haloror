class InstallsController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::TagHelper
  include RedboxHelper
  
  def activate_user
    @user = User.find(params[:user_id])
    @user.activate
    redirect_to :controller => 'sessions', :action => 'destroy'
  end
  def index
    @groups = []
    gs = current_user.group_memberships
    gs.each do |g| 
      @groups << g if(current_user.is_installer_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
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
    if check_params_for_group
      @group = Group.find_by_name(params[:group])
      conds = "name = 'halouser' AND authorizable_type = 'Group' AND authorizable_id = #{@group.id}"
      @role = Role.find(:first, :conditions => conds)
      @users = User.paginate(:page    => params[:page],
                             :include     => [:roles_users], 
                             #                         :conditions  => "users.id NOT IN (SELECT devices_users.user_id from devices_users) AND roles_users.role_id = #{@role.id}",
                             :conditions  => "roles_users.role_id = #{@role.id}",
      :order       => "users.id asc",
      :per_page    => 10)
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
      @gateway = Device.find_by_serial_number(gateway_serial_number)
      unless @gateway
        @gateway = @user.devices.build(params[:gateway])
      end
      begin
        @gateway.set_gateway_type
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
      @strap = Device.find_by_serial_number(strap_serial_number)
      if @strap && !@strap.users.blank? && !@strap.users.include?(@user)
        flash[:warning] = "Chest Strap with Serial Number #{strap_serial_number} is already assigned to a user."
        @remove_link = true
        throw Exception.new
      end
      unless @strap
        @strap = @user.devices.build(params[:strap]) 
      end
      begin
        @strap.set_chest_strap_type
      rescue Exception => e
        flash[:warning] = "#{e}"
        throw e
      end
    else
      msg = "Chest Strap Serial Number cannot be blank."
      flash[:warning] = msg
      throw msg
    end
    if(@gateway.users.blank? || (!@gateway.users.blank? && !@gateway.users.include?(@user)))
      @user.devices << @gateway
    end
    if(@strap.users.blank?)
      @user.devices << @strap
    end
    @user.save!
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
  
  def install_wizard_registration_progress
    init_devices_user
    message = 'Registering'
    self_test_step = check_registered()
    #self_test_step = false
    if self_test_step
      session[:progress_count][:register] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('registered_div_id', message, 'updateCheckRegistration', 'updateCheckSelfTestGateway', 'registered_check', 'update_percentage', REGISTRATION_PERCENTAGE, self_test_step.timestamp - session[:self_test_time_created])
    elsif check_registration_timeout?
      session[:progress_count][:register] = nil
      step = create_self_test_step(REGISTRATION_TIMEOUT_ID)
      @self_test_step = step
      @self_test_step_id = step.id
      message = 'Registration timed out.  <br><br>Press the panic button to take strap out of low power mode.  <br><br>Please ensure that the LED labeled "WAN" on the Gateway is green and then restart the wizard.'
      render_update_timeout('registered_div_id', message, 'updateCheckRegistration', 'install_wizard_launch')
    else
      render_update_message('registered_div_id', message, :register)
    end
  end
  
  
  def install_wizard_gateway_progress
    init_devices_user
    message = 'Gateway Self Test'
    battery_msg = check_battery_critical?
    if !battery_msg
      self_test_step = check_gateway_self_test()
      if self_test_step
        session[:progress_count][:gateway] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{REGISTRATION_COMPLETE_ID}")
        message = self_test_step.self_test_step_description.description
        render_update_success('gateway_div_id', message, 'updateCheckSelfTestGateway', 'updateCheckSelfTestChestStrap', 
                              'self_test_gateway_check', 'update_percentage', GATEWAY_SELF_TEST_PERCENTAGE, self_test_step.timestamp - previous_step.timestamp)
      elsif check_gateway_timeout?
        session[:progress_count][:gateway] = nil
        step = create_self_test_step(SELF_TEST_GATEWAY_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Please check your power and ethernet connection on your gateway."
        clear_session_data
        render_update_timeout('gateway_div_id', message, 'updateCheckSelfTestGateway', 'install_wizard_launch')
      elsif session[:halo_check_gateway_self_test_result] && !session[:halo_check_gateway_self_test_result].result
        step = create_self_test_step(SELF_TEST_GATEWAY_FAILED_ID)
        @self_test_step_id = step.id
        message = "Gateway Self Test failed"
        render_update_failure('gateway_div_id', message, 'updateCheckSelfTestGateway', 'install_wizard_launch')
      else
        render_update_message('gateway_div_id', message, :gateway)
      end
    else
      render_update_battery_critical('battery_critical_div_id', battery_msg, 'updateCheckSelfTestGateway')
    end
  end
  
  def install_wizard_chest_strap_progress
    init_devices_user
    message = 'Chest Strap Self Test'
    battery_msg = check_battery_critical?
    if !check_battery_critical?
    self_test_step = check_chest_strap_self_test()
      if self_test_step
        session[:progress_count][:chest_strap] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_GATEWAY_COMPLETE_ID}")
        message = self_test_step.self_test_step_description.description
        render_update_success('chest_strap_div_id', message, 'updateCheckSelfTestChestStrap', 'updateCheckSelfTestPhone', 
                              'self_test_chest_strap_check', 'update_percentage', CHEST_STRAP_SELF_TEST_PERCENTAGE, self_test_step.timestamp - previous_step.timestamp)
      elsif check_chest_strap_timeout?
        session[:progress_count][:chest_strap] = nil
        step = create_self_test_step(SELF_TEST_CHEST_STRAP_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Self Test Chest Strap timed out."
        clear_session_data
        render_update_timeout('chest_strap_div_id', message, 'updateCheckSelfTestChestStrap', 'install_wizard_launch')
      elsif session[:halo_check_chest_strap_self_test_result] && !session[:halo_check_chest_strap_self_test_result].result
        step = create_self_test_step(SELF_TEST_CHEST_STRAP_FAILED_ID)
        @self_test_step_id = step.id
        message = "Self Test Chest Strap failed.  To reset your chest strap please plug it in and hold panic button for 7 seconds."
        render_update_failure('chest_strap_div_id', message, 'updateCheckSelfTestChestStrap', 'install_wizard_launch')
      else
        render_update_message('chest_strap_div_id', message, :chest_strap)
      end
    else
      render_update_battery_critical('battery_critical_div_id', battery_msg, 'updateCheckSelfTestChestStrap')
    end
  end
  
  def flash_install_upgrade
    
  end
  
  def install_wizard_phone_progress
    init_devices_user
    message = 'Phone Self Test'
    battery_msg = check_battery_critical?
    if !check_battery_critical?
      self_test_step = check_phone_self_test()
      if self_test_step
        session[:progress_count][:phone] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_CHEST_STRAP_COMPLETE_ID}")
        duration = 0
        if((self_test_step.timestamp - previous_step.timestamp) > 0)
          duration = self_test_step.timestamp - previous_step.timestamp
        end
        message = self_test_step.self_test_step_description.description
        render_update_success('phone_div_id', message, 'updateCheckSelfTestPhone', 'updateCheckHeartrate', 
                              'self_test_phone_check', 'update_percentage', PHONE_SELF_TEST_PERCENTAGE, duration)
      elsif check_phone_timeout?
        session[:progress_count][:phone] = nil
        step = create_self_test_step(SELF_TEST_PHONE_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Self Test Phone timeout.  Please use phone to check for dial tone and plug phone line in to gateway.  Either restart the wizard or you can agree to disable the dial backup feature and continue by clicking <a href=\"javascript:continueWithoutPhone(" + @self_test_step_id.to_s + ");\" >here</a>."
        # clear_session_data
        render_update_timeout('phone_div_id', message, 'updateCheckSelfTestPhone', 'install_wizard_launch')
      elsif session[:halo_check_phone_self_test_result] && !session[:halo_check_phone_self_test_result].result
        step = create_self_test_step(SELF_TEST_PHONE_FAILED_ID)
        @self_test_step_id = step.id
        message = "Self Test Phone failed. Either restart the wizard or you can agree to disable the dial backup feature and continue by clicking <a href=\"javascript:continueWithoutPhone(" + @self_test_step_id.to_s + ");\" >Continue</a>."
        render_update_failure('phone_div_id', message, 'updateCheckSelfTestPhone', 'install_wizard_launch')
      else
        render_update_message('phone_div_id', message, :phone)
      end
    else
      render_update_battery_critical('battery_critical_div_id', battery_msg, 'updateCheckSelfTestPhone')
    end
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
        message = "Strap Fastened Detection timed out.  To reset your chest strap please plug it in and hold panic button for 7 seconds.  Please put on the chest strap and rerun the Installation Wizard."
        clear_session_data
        render_update_timeout('strap_fastened_div_id', message, 'updateCheckStrapFastened', 'install_wizard_launch')
      else
        render_update_message('strap_fastened_div_id', message, :strap_fastened)
      end
    else
      render_update_battery_critical('battery_critical_div_id', battery_msg, 'updateCheckStrapFastened')
    end
  end
  
  def install_wizard_heartrate_progress
    init_devices_user
    message = 'Detecting Heartrate'
    battery_msg = check_battery_critical?
    if !check_battery_critical?
      self_test_step = check_heartrate()
      if self_test_step
        session[:progress_count][:heartrate] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_PHONE_COMPLETE_ID}")
         unless previous_step
            previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_CHEST_STRAP_COMPLETE_ID}")
          end
        message = self_test_step.self_test_step_description.description
        render_update_success('heartrate_div_id', message, 'updateCheckHeartrate', nil, 
                              'heartrate_check', 'update_percentage', HEARTRATE_DETECTED_PERCENTAGE, self_test_step.timestamp - previous_step.timestamp, 'phone_test_complete', 'install_wizard_launch')
        
      elsif check_heartrate_timeout?
        session[:progress_count][:heartrate] = nil
        step = create_self_test_step(HEARTRATE_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Heartrate Detection timed out. To reset your chest strap please plug it in and hold panic button for 7 seconds.  Please put on the chest strap and rerun the Installation Wizard."
        clear_session_data
        render_update_timeout('heartrate_div_id', message, 'updateCheckHeartrate', 'install_wizard_launch')
      else
        render_update_message('heartrate_div_id', message, :heartrate)
      end
    else
      render_update_battery_critical('battery_critical_div_id', battery_msg, 'updateCheckHeartrate')
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
    strap = @user.get_strap
    @battery = Battery.find(:first, :conditions => "device_id = #{strap.id}", :order => 'timestamp desc')  
  end
  def start_range_test_only
    @user = User.find(params[:user_id])
    strap = @user.get_strap
    create_mgmt_cmd('range_test_start', strap.id)
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
    strap = @user.get_strap
    create_mgmt_cmd('range_test_stop', strap.id)
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
    
    render_update_success('range_test_div_id', message, nil, nil, 
                          'range_test_check', 'update_percentage', RANGE_TEST_PERCENTAGE, 
                          duration, 'notes', 'install_wizard_launch')
  end

  def notes
    init_devices_user
  end
  
  def submit_range_test_notes
    init_devices_user
    
    save_notes(@self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{RANGE_TEST_COMPLETE_ID}").id)
    launcher = new_remote_redbox('install_wizard_complete')
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