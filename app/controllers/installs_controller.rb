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
    if !params[:group].blank? && params[:group] != 'Choose a Group'
      redirect_to :action => 'users', :controller => 'installs', :group => params[:group]
    else
      redirect_to :controller => 'installs', :action => 'index'
    end
  end
  
  def users
    if !params[:group].blank? && params[:group] != 'Choose a Group'
      @group = Group.find_by_name(params[:group])
      @role = Role.find(:first, :conditions => "name = 'halouser' AND authorizable_type = 'Group' AND authorizable_id = #{@group.id}")
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
    if !params[:group].blank? && params[:group] != 'Choose a Group'
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
    #check if gateway exists
    if !params[:gateway][:serial_number].blank?
      @gateway = Device.find_by_serial_number(params[:gateway][:serial_number])
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
      flash[:warning] = "Gateway Serial Number cannot be blank."
      throw "Gateway Serial Number cannot be blank."
    end
    
    #check is strap exists and if it is assigned to a user or not
    #could have been registered without assigning a user
    if !params[:strap][:serial_number].blank?
      @strap = Device.find_by_serial_number(params[:strap][:serial_number])
      if @strap && !@strap.users.blank? && !@strap.users.include?(@user)
        flash[:warning] = "Chest Strap with Serial Number #{params[:strap][:serial_number]} is already assigned to a user."
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
      flash[:warning] = "Chest Strap Serial Number cannot be blank."
      throw "Chest Strap Serial Number cannot be blank."
    end
    if(@gateway.users.blank? || (!@gateway.users.blank? && !@gateway.users.include?(@user)))
      @user.devices << @gateway
    end
    if(@strap.users.blank?)
      @user.devices << @strap
    end
    @user.save!
    now = Time.now
#    MgmtCmd.create(:cmd_type            => 'self_test', 
#                     :device_id           => @strap.id, 
#                     :user_id             => @user.id,
#                     :creator             => current_user,
#                     :originator          => 'server',
#                     :pending             => true,
#                     :pending_on_ack      => true,                     
#                     :timestamp_initiated => now)
    
    MgmtCmd.create(:cmd_type            => 'self_test_phone', 
                     :device_id           => @gateway.id, 
                     :user_id             => @user.id,
                     :creator             => current_user,
                     :originator          => 'server',
                     :pending             => true,
                     :pending_on_ack      => true,                     
                     :timestamp_initiated => now)
  redirect_to :action => 'install_wizard', :controller => 'installs', :gateway_id => @gateway.id, :strap_id => @strap.id, :user_id => @user.id
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR registering devices, #{e}")
    render :action => 'registration'
  end
  
  def install_wizard
    init_devices_user
    session[:halo_install_wizard_timeout] = INSTALL_WIZARD_TIMEOUT.seconds.from_now
    session[:halo_install_wizard_start_timestamp_delay] = INSTALL_WIZARD_START_TIMESTAMP_DELAY.seconds.ago
  end
  
  def install_wizard_progress
    failure = false
    init_devices_user
    text = 'Registering...'
    message = ''
    percentage = 0
    self_test_step = nil
    if(self_test_step = check_phone_self_test(@user, @gateway_id))
      percentage = PHONE_SELF_TEST_PERCENTAGE
      text = self_test_step.self_test_step_description.description
    elsif(self_test_step = check_chest_strap_self_test(@user, @strap_id))
      percentage = CHEST_STRAP_SELF_TEST_PERCENTAGE
      text = self_test_step.self_test_step_description.description
    elsif(self_test_step = check_gateway_self_test(@user, @gateway_id))
      percentage = GATEWAY_SELF_TEST_PERCENTAGE
      text = self_test_step.self_test_step_description.description
    elsif(self_test_step = check_registered(@user, @gateway_id, @strap_id))
      percentage = REGISTRATION_PERCENTAGE
      text = self_test_step.self_test_step_description.description
    end
    checked = "/images/checkbox.png"
    #
    #
    #
    #
#    percentage = 70
    message = text
    render(:update) do |page| 
      page.call('update_percentage', percentage)
      if(percentage == PHONE_SELF_TEST_PERCENTAGE)
        page.call('update_self_test', false)
        page['registered_check'].src = checked
        page['self_test_gateway_check'].src = checked
        page['self_test_chest_strap_check'].src = checked
        page['self_test_phone_check'].src = checked
        launcher = launch_remote_redbox(:url =>{ :gateway_id => @gateway_id, :strap_id => @strap_id, :user_id => @user.id, :controller => "installs", :action => 'self_test_complete'}, :html => {:method => :get, :complete => ''})
      elsif(percentage == CHEST_STRAP_SELF_TEST_PERCENTAGE)
        page['registered_check'].src = checked
        page['self_test_gateway_check'].src = checked
        page['self_test_chest_strap_check'].src = checked
        if session[:halo_check_phone_self_test_result] && !session[:halo_check_phone_self_test_result].result
          message = "Phone self test failed."
          failure = true
        end
      elsif(percentage == GATEWAY_SELF_TEST_PERCENTAGE)
        page['registered_check'].src = checked
        page['self_test_gateway_check'].src = checked
        if session[:halo_check_chest_strap_self_test_result] && !session[:halo_check_chest_strap_self_test_result].result
          message = "Self test failed on Halo Chest Strap."
          failure = true
        end        
      elsif(percentage == REGISTRATION_PERCENTAGE)
        page['registered_check'].src = checked 
        if session[:halo_check_gateway_self_test_result] && !session[:halo_check_gateway_self_test_result].result
          message = "Self test failed on Halo Gateway."
          failure = true
        end 
      end
      page.replace_html 'install_wizard_result', message
      page.replace_html 'install_wizard_launch', launcher
      if failure
        message = "<b>Installation Failed:</b>  #{message}"
        page.replace_html 'install_wizard_result', message
        page.replace_html 'install_wizard_launch', launch_remote_redbox(:url =>{ :message => message, :gateway_id => @gateway_id, :strap_id => @strap_id, :user_id => @user.id, :controller => "installs", :action => 'failure_notice'}, :html => {:method => :get, :complete => ''})
        page.call('update_self_test', false)
      end
    end
  end
  def failure_notice
    @failure_notice = params[:message]
    init_devices_user
  end
  def self_test_complete
    init_devices_user
    MgmtCmd.create(:cmd_type            => 'range_test_start', 
                     :device_id           => @strap.id, 
                     :user_id             => @user.id,
                     :creator             => current_user,
                     :originator          => 'server',
                     :pending             => true,
                     :pending_on_ack      => true,                     
                     :timestamp_initiated => Time.now)
  end
  
  def install_wizard_vitals
    init_devices_user
    launcher=''
    message=''
    delay = session[:halo_install_wizard_start_timestamp_delay]
    checked = "/images/checkbox.png"
    @strap_fastened = StrapFastened.find(:first, :conditions => "user_id = #{@user.id} AND device_id = #{@strap_id} AND timestamp > '#{delay.to_s}'")
    percentage = nil
    render(:update) do |page|
      if @strap_fastened
        page[:strap_check].src = checked
        percentage = CHEST_STRAP_DETECTED_PERCENTAGE
        self_test_step_description = SelfTestStepDescription.find(CHEST_STRAP_TEST_STEP_DESCRIPTION_ID)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => @user.id)
        message = self_test_step_description.description
        @vital = Vital.find(:first, :conditions => "user_id = #{@user.id} AND heartrate != -1 AND timestamp > '#{delay.to_s}'")
        if @vital
          page[:heartrate_check].src = checked
          page[:heartrate_detected].replace_html "Heartrate Detected:  #{@vital.heartrate}"
          percentage = HEARTRATE_DETECTED_PERCENTAGE
          self_test_step_description = SelfTestStepDescription.find(HEARTRATE_TEST_STEP_DESCRIPTION_ID)    
          self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => @user.id)
          message = self_test_step_description.description                
          launcher = launch_remote_redbox(:url =>{ :gateway_id => @gateway_id, 
                                                  :strap_id => @strap_id, 
                                                  :user_id => @user.id, 
                                                  :controller => "installs", 
                                                  :action => 'vitals_complete'}, 
                                         :html => {:method => :get, :complete => ''})
        end
      end
      page.call("update_percentage", percentage) if percentage
      page.replace_html 'install_wizard_result', message
      page.replace_html 'vitals_complete_div', launcher
    end
  end
  
  def vitals_complete
    init_devices_user
  end
  
  def start_range_test
    init_devices_user
    render(:update) do |page|
      launcher = launch_remote_redbox(:url =>{ :gateway_id => @gateway_id, 
                                                  :strap_id => @strap_id, 
                                                  :user_id => @user.id, 
                                                  :controller => "installs", 
                                                  :action => 'range_test'}, 
                                         :html => {:method => :get, :complete => ''})
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
    message = "Range Test Complete"
    MgmtCmd.create(:cmd_type              => 'mgmt_poll_rate', 
                     :device_id           => @strap.id, 
                     :user_id             => @user.id,
                     :creator             => current_user,
                     :originator          => 'server',
                     :pending             => true,
                     :pending_on_ack      => true,                     
                     :timestamp_initiated => Time.now,
                     :param1              => MGMT_POLL_RATE)
    render(:update) do |page|
      page.replace_html 'install_wizard_result', message
    end
  end
  private
  
  def init_devices_user
    @gateway_id = params[:gateway_id]
    @strap_id = params[:strap_id]
    @user = User.find(params[:user_id])
    @gateway = Device.find(@gateway_id)
    @strap = Device.find(@strap_id)
  end
  
  def check_phone_self_test(user, gateway_id)
    delay = session[:halo_install_wizard_start_timestamp_delay]
    if(!session[:halo_check_phone_self_test])
      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test_phone' AND result = true AND timestamp > '#{delay.to_s}'")
      if @self_test
        self_test_step_description = SelfTestStepDescription.find(PHONE_SELF_TEST_STEP_DESCRIPTION_ID)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => user.id)
        session[:halo_check_phone_self_test] = self_test_step
        session[:halo_check_phone_self_test_result] = @self_test
        return self_test_step
      else
        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test_phone' AND result = false AND timestamp > '#{delay.to_s}'")        
        session[:halo_check_phone_self_test_result] = @self_test
        return false
      end
    else
      return session[:halo_check_phone_self_test]
    end
  end
  
  def check_chest_strap_self_test(user, strap_id)
#    delay = session[:halo_install_wizard_start_timestamp_delay]
#    if(!session[:halo_check_chest_strap_self_test])
#      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{strap_id} AND cmd_type = 'self_test' AND result = true AND timestamp > '#{delay.to_s}'")
#      if @self_test
#        self_test_step_description = SelfTestStepDescription.find(CHEST_STRAP_SELF_TEST_STEP_DESCRIPTION_ID)    
#        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
#                          :timestamp => Time.now,
#                          :user_id => current_user.id, 
#                          :halo_user_id => user.id)
#        session[:halo_check_chest_strap_self_test] = self_test_step
#        return self_test_step
#      else
#        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{strap_id} AND cmd_type = 'self_test' AND result = false AND timestamp > '#{delay.to_s}'")
#        return false
#      end
#    else
#      return session[:halo_check_chest_strap_self_test]
#    end
    @self_test = SelfTestResult.new(:result => true, :cmd_type => 'self_test', :device_id => @strap_id, :timestamp => Time.now)
    self_test_step_description = SelfTestStepDescription.find(CHEST_STRAP_SELF_TEST_STEP_DESCRIPTION_ID)    
    self_test_step = SelfTestStep.new(:self_test_step_description_id => self_test_step_description.id,
                      :timestamp => Time.now,
                      :user_id => current_user.id, 
                      :halo_user_id => user.id)
    self_test_step.self_test_step_description = self_test_step_description
    session[:halo_check_chest_strap_self_test] = self_test_step
    session[:halo_check_chest_strap_self_test_result] = @self_test
    return self_test_step
  end
  
  def check_gateway_self_test(user, gateway_id)
    delay = session[:halo_install_wizard_start_timestamp_delay] - GATEWAY_SELF_TEST_DELAY.seconds
    if(!session[:halo_check_gateway_self_test])
      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test' AND result = true AND timestamp > '#{delay.to_s}'")
      if @self_test
        self_test_step_description = SelfTestStepDescription.find(GATEWAY_SELF_TEST_STEP_DESCRIPTION_ID)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => user.id)
        session[:halo_check_gateway_self_test] = self_test_step
        session[:halo_check_gateway_self_test_result] = @self_test
        return self_test_step
      else
        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test' AND result = false AND timestamp > '#{delay.to_s}'")
        session[:halo_check_gateway_self_test_result] = @self_test
        return false
      end
    else
      return session[:halo_check_gateway_self_test]
    end
  end
  
  def check_registered(user, gateway_id, strap_id)
    if(!session[:halo_check_registered])
      user_registration_mgmt_cmd_strap   =  MgmtCmd.find(:first, :conditions => "device_id = #{strap_id} AND user_id = #{user.id} AND cmd_type = 'user_registration'")
      
      if(user_registration_mgmt_cmd_strap && user.devices.find(gateway_id) && user.devices.find(strap_id))
        self_test_step_description = SelfTestStepDescription.find(REGISTRATION_SELF_TEST_STEP_DESCRIPTION_ID)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => user.id)
        session[:halo_check_registered] = self_test_step
        return self_test_step
      else
        return false
      end
    else
      return session[:halo_check_registered]
    end
  end
end