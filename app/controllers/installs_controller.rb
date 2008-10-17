class InstallsController < ApplicationController
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::TagHelper
  include RedboxHelper
  
  
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
    if check_params_for_group
      @group = Group.find_by_name(params[:group])
      if !params[:id].blank?
        @id = params[:id]
        @user = User.find(@id)
        @gateway = Device.new
        @strap = Device.new
        
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
    @self_test_session = SelfTestSession.create(:created_at => Time.now, :user_id => @user.id, :created_by => current_user.id)
    @self_test_session_id = @self_test_session_id
    gateway_serial_number = params[:gateway][:serial_number]
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
    strap_serial_number = params[:strap][:serial_number]
    if !strap_serial_number.blank?
      @strap = Device.find_by_serial_number(strap_serial_number)
      if @strap && !@strap.users.blank? && !@strap.users.include?(@user)
        flash[:warning] = "Chest Strap with Serial Number #{strap_serial_number} is already assigned to a user."
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
    now = Time.now
    #   create_self_test_step(SELF_TEST_CHEST_STRAP_MGMT_COMMAND_CREATED_ID)
    #    MgmtCmd.create(:cmd_type            => 'self_test', 
    #                     :device_id           => @strap.id, 
    #                     :user_id             => @user.id,
    #                     :creator             => current_user,
    #                     :originator          => 'server',
    #                     :pending             => true,
    #                     :pending_on_ack      => true,                     
    #                     :timestamp_initiated => now)
    
    create_self_test_step(SELF_TEST_PHONE_MGMT_COMMAND_CREATED_ID)
    MgmtCmd.create(:cmd_type            => 'self_test_phone', 
    :device_id           => @gateway.id, 
    :user_id             => @user.id,
    :creator             => current_user,
    :originator          => 'server',
    :pending             => true,
    :pending_on_ack      => true,                     
    :timestamp_initiated => now)
    redirect_to :action => 'install_wizard', :controller => 'installs',
    :self_test_session_id => @self_test_session_id,
    :gateway_id => @gateway.id, :strap_id => @strap.id, :user_id => @user.id
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR registering devices, #{e}")
    create_self_test_step(INSTALLATION_SERIAL_NUMBERS_ENTERED_FAILED_ID)
    render :action => 'registration'
  end
  
  def install_wizard
    init_devices_user
    session[:progress_count]= {}
  end
  
  def install_wizard_registration_progress
    init_devices_user
    message = 'Registering'
    self_test_step = check_registered()
    #self_test_step = false
    if self_test_step
      session[:progress_count][:register] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('registered_div_id', message, 'updateCheckRegistration', 'updateCheckSelfTestGateway', 'registered_check', 'update_percentage', REGISTRATION_PERCENTAGE)
    else
      render_update_message('registered_div_id', message, :register)
    end
  end
  
  def install_wizard_gateway_progress
    init_devices_user
    message = 'Gateway Self Test'
    self_test_step = check_gateway_self_test()
    if self_test_step
      session[:progress_count][:gateway] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('gateway_div_id', message, 'updateCheckSelfTestGateway', 'updateCheckSelfTestChestStrap', 'self_test_gateway_check', 'update_percentage', GATEWAY_SELF_TEST_PERCENTAGE)
    elsif check_gateway_timeout?
      session[:progress_count][:gateway] = nil
      step = create_self_test_step(SELF_TEST_GATEWAY_TIMEOUT_ID)
      message = "<b>Installation Failed (Timeout):</b>  #{step.self_test_step_description.description}"
      render_update_timeout('gateway_div_id', message, 'updateCheckSelfTestGateway', 'install_wizard_launch')
    elsif session[:halo_check_gateway_self_test_result] && !session[:halo_check_gateway_self_test_result].result
      step = create_self_test_step(SELF_TEST_GATEWAY_FAILED_ID)
      message = step.self_test_step_description.description
      render_update_failure('gateway_div_id', message, 'updateCheckSelfTestGateway', 'install_wizard_launch')
    else
      render_update_message('gateway_div_id', message, :gateway)
    end
  end
  
  def install_wizard_chest_strap_progress
    init_devices_user
    message = 'Chest Strap Self Test'
    self_test_step = check_chest_strap_self_test()
    if self_test_step
      session[:progress_count][:chest_strap] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('chest_strap_div_id', message, 'updateCheckSelfTestChestStrap', 'updateCheckSelfTestPhone', 'self_test_chest_strap_check', 'update_percentage', CHEST_STRAP_SELF_TEST_PERCENTAGE)
    elsif check_chest_strap_timeout?
      session[:progress_count][:chest_strap] = nil
      step = create_self_test_step(SELF_TEST_CHEST_STRAP_TIMEOUT_ID)
      message = "<b>Installation Failed (Timeout):</b>  #{step.self_test_step_description.description}"
      render_update_timeout('chest_strap_div_id', message, 'updateCheckSelfTestChestStrap', 'install_wizard_launch')
    elsif session[:halo_check_chest_strap_self_test_result] && !session[:halo_check_chest_strap_self_test_result].result
      step = create_self_test_step(SELF_TEST_CHEST_STRAP_FAILED_ID)
      message = step.self_test_step_description.description
      render_update_failure('chest_strap_div_id', message, 'updateCheckSelfTestChestStrap', 'install_wizard_launch')
    else
      render_update_message('chest_strap_div_id', message, :chest_strap)
    end
  end
  
  def install_wizard_phone_progress
    init_devices_user
    message = 'Phone Self Test'
    self_test_step = check_phone_self_test()
    if self_test_step
      session[:progress_count][:phone] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('phone_div_id', message, 'updateCheckSelfTestPhone', 'updateCheckStrapFastened', 'self_test_phone_check', 'update_percentage', PHONE_SELF_TEST_PERCENTAGE)
    elsif check_chest_strap_timeout?
      session[:progress_count][:phone] = nil
      step = create_self_test_step(SELF_TEST_PHONE_TIMEOUT_ID)
      message = "<b>Installation Failed (Timeout):</b>  #{step.self_test_step_description.description}"
      render_update_timeout('phone_div_id', message, 'updateCheckPhone', 'install_wizard_launch')
    elsif session[:halo_check_phone_self_test_result] && !session[:halo_check_phone_self_test_result].result
      step = create_self_test_step(SELF_TEST_PHONE_FAILED_ID)
      message = step.self_test_step_description.description
      render_update_failure('phone_div_id', message, 'updateCheckPhone', 'install_wizard_launch')
    else
      render_update_message('phone_div_id', message, :phone)
    end
  end
  
  def failure_notice
    @failure_notice = params[:message]
    init_devices_user
  end
  def self_test_complete
    init_devices_user
    MgmtCmd.create(  :cmd_type            => 'range_test_start', 
    :device_id           => @strap.id, 
    :user_id             => @user.id,
    :creator             => current_user,
    :originator          => 'server',
    :pending             => true,
    :pending_on_ack      => true,                     
    :timestamp_initiated => Time.now)
  end
  
  def install_wizard_strap_fastened_progress
    init_devices_user
    message = 'Detecting Strap Fastened'
    self_test_step = check_strap_fastened()
    if self_test_step
      session[:progress_count][:strap_fastened] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('strap_fastened_div_id', message, 'updateCheckStrapFastened', 'updateCheckHeartrate', 'strap_fastened_check', 'update_percentage', CHEST_STRAP_DETECTED_PERCENTAGE)
    elsif check_strap_fastened_timeout?
      session[:progress_count][:strap_fastened] = nil
      step = create_self_test_step(CHEST_STRAP_FASTENED_TIMEOUT_ID)
      message = "<b>Installation Failed (Timeout):</b>  #{step.self_test_step_description.description}"
      render_update_timeout('strap_fastened_div_id', message, 'updateCheckStrapFastened', 'install_wizard_launch')
    else
      render_update_message('strap_fastened_div_id', message, :strap_fastened)
    end
  end
  
  def install_wizard_heartrate_progress
    init_devices_user
    message = 'Detecting Heartrate'
    self_test_step = check_heartrate()
    if self_test_step
      session[:progress_count][:heartrate] = nil
      message = self_test_step.self_test_step_description.description
      render_update_success('heartrate_div_id', message, 'updateCheckHeartrate', nil, 'heartrate_check', 'update_percentage', HEARTRATE_DETECTED_PERCENTAGE, 'vitals_complete', 'install_wizard_launch')
      
    elsif check_heartrate_timeout?
      session[:progress_count][:heartrate] = nil
      step = create_self_test_step(HEARTRATE_TIMEOUT_ID)
      message = "<b>Installation Failed (Timeout):</b>  #{step.self_test_step_description.description}"
      render_update_timeout('heartrate_div_id', message, 'updateCheckHeartrate', 'install_wizard_launch')
    else
      render_update_message('heartrate_div_id', message, :heartrate)
    end
  end
  
  def vitals_complete
    init_devices_user
  end
  
  def start_range_test
    init_devices_user
    create_self_test_step(START_RANGE_TEST_PROMPT_ID)
    render(:update) do |page|
      launcher = launch_remote_redbox(:url =>   { :gateway_id => @gateway_id, 
        :strap_id => @strap_id, 
        :user_id => @user.id,
        :self_test_session_id => @self_test_session_id, 
        :controller => "installs", 
        :action => 'range_test'}, 
      :html =>  { :method => :get, :complete => ''})
      page.replace_html 'range_test_start_div', launcher
      page.replace_html 'install_wizard_result', 'Range Test Started'
    end
  end
  
  def range_test
    init_devices_user
  end
  
  def stop_range_test
    init_devices_user
    MgmtCmd.create(:cmd_type            => 'range_test_stop', 
    :device_id           => @strap.id, 
    :user_id             => @user.id,
    :creator             => current_user,
    :originator          => 'server',
    :pending             => true,
    :pending_on_ack      => true,                     
    :timestamp_initiated => Time.now)
    message = create_self_test_step(STOP_RANGE_TEST_PROMPT_ID).self_test_step_description.description
    MgmtCmd.create(:cmd_type              => 'mgmt_poll_rate', 
    :device_id           => @strap.id, 
    :user_id             => @user.id,
    :creator             => current_user,
    :originator          => 'server',
    :pending             => true,
    :pending_on_ack      => true,                     
    :timestamp_initiated => Time.now,
    :param1              => MGMT_POLL_RATE)
    create_self_test_step(SLOW_POLLING_MGMT_COMMAND_CREATED_ID)
    render(:update) do |page|
      page.replace_html 'install_wizard_result', message
      page.replace_html launch_id,
      launch_remote_redbox(:url =>  {  :self_test_session_id => @self_test_session_id,
        :message => "Installation Complete", :gateway_id => @gateway_id, :strap_id => @strap_id, :user_id => @user.id, 
        :controller => "installs", :action => 'install_wizard_complete' }, 
      :html => { :method => :get, :complete => '' } )
    end
  end
  
  def install_wizard_complete
    init_devices_user
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
    delay = @self_test_session.created_at
    conds = "user_id = #{@user.id} AND heartrate != -1 AND timestamp > '#{delay.to_s}'"
    @vital = Vital.find(:first, :conditions => conds)
    if @vital    
      create_self_test_step(HEARTRATE_DETECTED_ID)
    else
      return false
    end
  end
  def timeout?(self_test_step_description_id, num)
    step = @self_test_session.self_test_steps.find(:first,:conditions => "self_test_step_description_id = #{self_test_step_description_id}")
    if Time.now > (step.timestamp + num.minutes)
      return true
    else
      return false
    end
  end
  def check_heartrate_timeout?
    timeout?(CHEST_STRAP_FASTENED_DETECTED_ID, 2)
  end
  
  def check_gateway_timeout?
    if Time.now > (@self_test_session.created_at + 2.minutes)
      return true
    else
      return false
    end
  end
  
  def check_chest_strap_timeout?
    timeout?(SELF_TEST_GATEWAY_COMPLETE_ID, 3)
  end
  
  def check_strap_fastened_timeout?
    timeout?(CHEST_STRAP_PROMPT_ID, 2)
  end
  def progress_count(sym)
    if session[:progress_count][sym]
      session[:progress_count][sym] += 1
    else 
      session[:progress_count][sym] = 1
    end
    if session[:progress_count][sym] > 80
      session[:progress_count][sym] = 1
    end
    return session[:progress_count][sym]
  end
  def render_update_success(message_id, message, false_id, true_id, image_id, update_percentage_id, percentage, action=nil, launch_id=nil )
    render(:update) do |page|
      page.call(false_id, false)
      page[image_id].src = "/images/checkbox.png"
      page.call(update_percentage_id, percentage)
      page.replace_html message_id, message
      if true_id
        page.call(true_id, true)
      end
      if action && launch_id
        page.replace_html launch_id, 
        launch_remote_redbox(:url =>  { :self_test_session_id => @self_test_session_id,
          :message => message, :gateway_id => @gateway_id, :strap_id => @strap_id, :user_id => @user.id, 
          :controller => "installs", :action => action }, 
        :html => { :method => :get, :complete => '' } )
      end
    end
  end
  
  def render_update_timeout(message_id, message, false_id, launch_id)
    render(:update) do |page|
      page.call(false_id, false)
      page.replace_html message_id, message
      page.replace_html launch_id, 
      launch_remote_redbox(:url =>  { :self_test_session_id => @self_test_session_id,
        :message => message, :gateway_id => @gateway_id, :strap_id => @strap_id, :user_id => @user.id, 
        :controller => "installs", :action => 'failure_notice' }, 
      :html => { :method => :get, :complete => '' } )
    end
  end
  
  def render_update_failure(message_id, message, false_id, launch_id)
    render(:update) do |page|
      page.call(false_id, false)
      page.replace_html message_id, message
      page.replace_html launch_id,
      launch_remote_redbox(:url =>  {  :self_test_session_id => @self_test_session_id,
        :message => message, :gateway_id => @gateway_id, :strap_id => @strap_id, :user_id => @user.id, 
        :controller => "installs", :action => 'failure_notice' }, 
      :html => { :method => :get, :complete => '' } )
    end
  end
  
  def render_update_message(message_id, message, sym)
    count = progress_count(sym)
    render(:update) do |page|
     (0..count).each do |i|
        message += '.'
      end
      page.replace_html message_id, message
    end
  end
end