class InstallerController < ApplicationController
  #include 'registration_helper'
  def index
    
  end
   
  def add_caregiver
    init_user_group
    init_devices_self_test_session
    if(!params[:caregiver_email].blank?)
     User.transaction do
      @caregiver = User.new
      @caregiver.email = params[:caregiver_email]
      @caregiver.is_new_caregiver = true
      @caregiver[:is_caregiver] =  true
      @caregiver.save!
      profile = Profile.new(:user_id => @caregiver.id)
      profile[:is_new_caregiver] = true
      profile.save!
      role = @caregiver.has_role 'caregiver', @user
      @roles_user = @user.roles_user_by_caregiver(@caregiver)
    
      RolesUsersOption.create(:roles_user_id => @roles_user.id, 
                              :position => get_max_caregiver_position(@user), 
                              :active => 0)
      #redirect_to "/profiles/edit_caregiver_profile/#{profile.id}/?user_id=#{params[:user_id]}&roles_user_id=#{@roles_user.id}"
      UserMailer.deliver_caregiver_email(@caregiver, @user)
      @caregiver_added = @caregiver
      params[:email] = params[:caregiver_email]
     end
    else
      flash[:warning] = "Email Required"
    end
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
  
  def remove_user_mapping
    user_id = params[:user_id]
    device_id = params[:device_id]
    Device.connection.delete "delete from devices_users where device_id = #{device_id}"
    redirect_to :action => 'registration_create_step', :controller => 'installer', 
                  :user_id => user_id,  :self_test_session_id => params[:self_test_session_id],
                  :gateway_serial_number => params[:gateway_serial_number], :strap_serial_number => params[:strap_serial_number]
  end
  
  def flash_check_step
    init_user_group
  end
  
  def charge_check_step
    init_user_group
  end
  
  def ethernet_check_step
    init_user_group
  end
  
  def led_check_step
    init_user_group
  end
  
  def registration_step
    clear_session_data
    init_user_group
    @gateway = Device.new
    @strap = Device.new
    @self_test_session = SelfTestSession.create(:created_at => Time.now.utc, :user_id => @user.id, :created_by => current_user.id)
    @self_test_session_id = @self_test_session.id
  end
  
  def registration_create_step
    init_user_group
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
      	params[:gateway][:serial_number] = gateway_serial_number
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
        flash[:warning] = "Chest Strap with Serial Number #{strap_serial_number} is already assigned to a user."
        @remove_link = true
        throw Exception.new
      end
      unless @strap
      	params[:strap][:serial_number] = strap_serial_number
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
    redirect_to :action => 'installer', :controller => 'installer', :self_test_session_id => @self_test_session_id,
                :gateway_id => @gateway.id, :strap_id => @strap.id, :user_id => @user.id
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR registering devices, #{e}")
    create_self_test_step(INSTALLATION_SERIAL_NUMBERS_ENTERED_FAILED_ID)
    render :action => 'registration_step'
  end

  def installer
    init_user_group
    init_devices_self_test_session    
    session[:progress_count]= {}
    create_mgmt_cmd('self_test', @gateway.id)
    create_self_test_step(SELF_TEST_PHONE_MGMT_COMMAND_CREATED_ID)
    create_mgmt_cmd('self_test_phone', @gateway.id)
  end
  
  def restart_installer
    init_user_group
    init_devices_self_test_session
    clear_session_data
    @self_test_session = SelfTestSession.create(:created_at => Time.now.utc, :user_id => @user.id, :created_by => current_user.id)
    @self_test_session_id = @self_test_session.id
    session[:self_test_time_created] = Time.now.utc
    redirect_to :action => 'installer', :controller => 'installer', :self_test_session_id => @self_test_session_id,
    :gateway_id => @gateway.id, :strap_id => @strap.id, :user_id => @user.id
  end

  def registration_progress
    init_user_group
    init_devices_self_test_session
    message = 'Registering'
    self_test_step = check_registered()
    if self_test_step
      session[:progress_count][:register] = nil
      message = self_test_step.self_test_step_description.description
      render(:update) do |page|
        page.call('updateCheckRegistration', false)
        page.replace_html('message_div_id', message)
        page.call('update_percentage', REGISTRATION_PERCENTAGE)
        page.call('updateCheckSelfTestGateway', true)
        # render_update_success('installer_div', message, 'updateCheckRegistration', 'updateCheckSelfTestGateway', 'registered_check', 'update_percentage', REGISTRATION_PERCENTAGE, self_test_step.timestamp - session[:self_test_time_created])
      end
    elsif check_registration_timeout?
      session[:progress_count][:register] = nil
      step = create_self_test_step(REGISTRATION_TIMEOUT_ID)
      @self_test_step = step
      @self_test_step_id = step.id
      message = 'Registration timed out.<br><br>The chest strap/belt clip wearer is either out of range of the gateway OR in low power mode. <br><br>If the chest strap/belt clip has been unplugged for more than 15 miutes, then press the panic button. <br><br> OR <br><br>If the chest strap/belt clip wearer is out of range of the gateway, please try to lay the antennae flat or try to move the gateway to another position.  <br><br> Once the strap is out of low power mode or back in range, the PAN LED on the gateway will turn green in approximately 1 minute. Please ensure that the WAN and PAN LEDs are green on the gateway and then restart the wizard.'
      str = <<-eos
          
          <div id="lightbox-col-700">
         	<img src="/images/lightbox-col-header-700.gif" /><br />
         	<div class="lightbox-content-700">
          		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
          			<div id="installer_div_id">
            			<div id="message_div_id" style="font-size: 125%;vertical-align: middle;">#{message}</div>
            			<div id="duration_div_id" style="vertical-align: middle;"></div>
          			</div>
          		</div>
          
        			<br />
        			<br />
        			<form action="/installer/restart_installer" method="post">
        				<input type="hidden" name="user_id" value="#{@user.id}" />
        				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
        				<input type="hidden" name="strap_id" value="#{@strap_id}" />
        				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
        				<span style="padding-left:30px">
        			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
        			</span>
        			</form>
            	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
        eos
        render(:update) do |page|
          page.call('updateCheckRegistration', false)
          page.replace_html('installer_div_id', str)
        end
    else
      # render_update_message('installer_div', message, :register)
      p_count = progress_count(:register)
      dts = dots(p_count)
      render(:update) do |page|
        page.replace_html('message_div_id', message)
        page.replace_html('duration_div_id', dts)
      end
    end
  end
  
  def gateway_progress
    init_user_group
    init_devices_self_test_session
    message = 'Gateway Self Test'
    battery_msg = check_battery_critical?
    if !battery_msg
      self_test_step = check_gateway_self_test()
      if self_test_step
        session[:progress_count][:gateway] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{REGISTRATION_COMPLETE_ID}")
        message = self_test_step.self_test_step_description.description
        render(:update) do |page|
          page.call('updateCheckSelfTestGateway', false)
          page.replace_html('message_div_id', message)
          page.call('update_percentage', GATEWAY_SELF_TEST_PERCENTAGE)
          page.call('updateCheckSelfTestChestStrap', true)
        end
      elsif check_gateway_timeout?
        session[:progress_count][:gateway] = nil
        step = create_self_test_step(SELF_TEST_GATEWAY_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Please check your power and ethernet connection on your gateway."
        clear_session_data
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              				<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckSelfTestGateway', false)
          page.replace_html('installer_div_id', str)
        end
      elsif session[:halo_check_gateway_self_test_result] && !session[:halo_check_gateway_self_test_result].result
        step = create_self_test_step(SELF_TEST_GATEWAY_FAILED_ID)
        @self_test_step_id = step.id
        message = "Gateway Self Test failed"
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              				<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckSelfTestGateway', false)
          page.replace_html('installer_div_id', str)
        end
      else
        # render_update_message('gateway_div_id', message, :gateway)
        p_count = progress_count(:gateway)
        dts = dots(p_count)
        render(:update) do |page|
          page.replace_html('message_div_id', message)
          page.replace_html('duration_div_id', dts)
        end
      end
    else
      str = <<-eos

      <div id="lightbox-col-700">
     	<img src="/images/lightbox-col-header-700.gif" /><br />
     	<div class="lightbox-content-700">
          		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
          			<div id="installer_div_id">
            			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{battery_msg}</div>
            			<div id="duration_div_id" style="vertical-align: middle;"></div>
          			</div>
          		</div>

            			<br />
            			<br />
            			<form action="/installer/restart_installer" method="post">
            				<input type="hidden" name="user_id" value="#{@user.id}" />
            				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
            				<input type="hidden" name="strap_id" value="#{@strap_id}" />
            				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
            				<span style="padding-left:30px">
            			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
            			</span>
            			</form>
                	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
        eos
      render(:update) do |page|
        page.call('updateCheckSelfTestGateway', false)
        page.replace_html('installer_div_id', str)
      end
    end
  end
  
  def chest_strap_progress
    init_user_group
    init_devices_self_test_session
    message = 'Chest Strap/Belt Clip Self Test'
    battery_msg = check_battery_critical?
    if !check_battery_critical?
    self_test_step = check_chest_strap_self_test()
      if self_test_step
        session[:progress_count][:chest_strap] = nil
        previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_GATEWAY_COMPLETE_ID}")
        message = self_test_step.self_test_step_description.description
        render(:update) do |page|
          page.call('updateCheckSelfTestChestStrap', false)
          page.replace_html('message_div_id', message)
          page.call('update_percentage', CHEST_STRAP_SELF_TEST_PERCENTAGE)
          page.call('updateCheckSelfTestPhone', true)
        end
      elsif check_chest_strap_timeout?
        session[:progress_count][:chest_strap] = nil
        step = create_self_test_step(SELF_TEST_CHEST_STRAP_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Self Test Chest Strap/Belt Clip timed out."
        clear_session_data
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              				<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckSelfTestChestStrap', false)
          page.replace_html('installer_div_id', str)
        end
      elsif session[:halo_check_chest_strap_self_test_result] && !session[:halo_check_chest_strap_self_test_result].result
        step = create_self_test_step(SELF_TEST_CHEST_STRAP_FAILED_ID)
        @self_test_step_id = step.id
        message = "Self Test Chest Strap/Belt Clip failed.  To reset your chest strap/belt clip please plug it in and hold panic button for 7 seconds."
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              				<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckSelfTestChestStrap', false)
          page.replace_html('installer_div_id', str)
        end
      else
        p_count = progress_count(:chest_strap)
        dts = dots(p_count)
        render(:update) do |page|
          page.replace_html('message_div_id', message)
          page.replace_html('duration_div_id', dts)
        end
      end
    else
      str = <<-eos

      <div id="lightbox-col-700">
     	<img src="/images/lightbox-col-header-700.gif" /><br />
     	<div class="lightbox-content-700">
          		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
          			<div id="installer_div_id">
            			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{battery_msg}</div>
            			<div id="duration_div_id" style="vertical-align: middle;"></div>
          			</div>
          		</div>

            			<br />
            			<br />
            			<form action="/installer/restart_installer" method="post">
            				<input type="hidden" name="user_id" value="#{@user.id}" />
            				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
            				<input type="hidden" name="strap_id" value="#{@strap_id}" />
            				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
            				<span style="padding-left:30px">
            			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
            			</span>
            			</form>
                	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
        eos
      render(:update) do |page|
        page.call('updateCheckSelfTestChestStrap', false)
        page.replace_html('installer_div_id', str)
      end
    end
  end
  
  def phone_progress
    init_user_group
    init_devices_self_test_session
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
        render(:update) do |page|
          page.call('updateCheckSelfTestPhone', false)
          page.replace_html('message_div_id', message)
          page.call('update_percentage', PHONE_SELF_TEST_PERCENTAGE)

          if @strap.device_type.eql? DEVICE_TYPES[:H5]
            page.call('updateCheckHeartrate', false)

          else
            page.call('updateCheckHeartrate', true)

          end
        end
      elsif check_phone_timeout?
        session[:progress_count][:phone] = nil
        step = create_self_test_step(SELF_TEST_PHONE_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Self Test of phone line timed out.  Please use a regular phone to check for a dial tone and plug the phone line back into the gateway.<br><br>You can continue without the phone line backup. Please be aware that continuing without the phone line backup disables the backup if your internet connection is temporarily down.<br><br><button onclick=\"javascript:continueWithoutPhone(" + @self_test_step_id.to_s + ");\" >Continue without Phone Backup</button><br><br>OR<br><br>You can try again by restarting the wizard:"
        # clear_session_data
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 125%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              				<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckSelfTestPhone', false)
          page.replace_html('installer_div_id', str)
        end
      elsif session[:halo_check_phone_self_test_result] && !session[:halo_check_phone_self_test_result].result
        step = create_self_test_step(SELF_TEST_PHONE_FAILED_ID)
        @self_test_step_id = step.id
        message = "Self Test of phone line failed.<br><br>You can continue without the phone line backup. Please be aware that continuing without the phone line backup disables the backup if your internet connection is temporarily down.<br><br><button onclick=\"javascript:continueWithoutPhone(" + @self_test_step_id.to_s + ");\" >Continue without Phone Backup</button><br><br>OR<br><br>You can try again by restarting the wizard:"
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 125%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              				<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckSelfTestPhone', false)
          page.replace_html('installer_div_id', str)
        end
      else
          p_count = progress_count(:phone)
          dts = dots(p_count)
          render(:update) do |page|
            page.replace_html('message_div_id', message)
            page.replace_html('duration_div_id', dts)
          end
      end
    else
      str = <<-eos

      <div id="lightbox-col-700">
     	<img src="/images/lightbox-col-header-700.gif" /><br />
     	<div class="lightbox-content-700">
          		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
          			<div id="installer_div_id">
            			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{battery_msg}</div>
            			<div id="duration_div_id" style="vertical-align: middle;"></div>
          			</div>
          		</div>

            			<br />
            			<br />
            			<form action="/installer/restart_installer" method="post">
            				<input type="hidden" name="user_id" value="#{@user.id}" />
            				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
            				<input type="hidden" name="strap_id" value="#{@strap_id}" />
            				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
            				<span style="padding-left:30px">
            			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
            			</span>
            			</form>
                	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
        eos
      render(:update) do |page|
        page.call('updateCheckSelfTestPhone', false)
        page.replace_html('installer_div_id', str)
      end
    end
  end
  
  def heartrate_progress
    init_user_group
    init_devices_self_test_session
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
        render(:update) do |page|
          page.replace_html('message_div_id', message)
          #page.call('update_percentage', HEARTRATE_DETECTED_PERCENTAGE)
            page.call('updateCheckHeartrate', false)
        end
      elsif check_heartrate_timeout?
        session[:progress_count][:heartrate] = nil
        step = create_self_test_step(HEARTRATE_TIMEOUT_ID)
        @self_test_step_id = step.id
        message = "Heartrate Detection timed out. To reset your chest strap please plug it in and hold panic button for 7 seconds.  Please put on the chest strap and rerun the Installation Wizard."
        clear_session_data
        str = <<-eos

        <div id="lightbox-col-700">
       	<img src="/images/lightbox-col-header-700.gif" /><br />
       	<div class="lightbox-content-700">
            		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
            			<div id="installer_div_id">
              			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{message}</div>
              			<div id="duration_div_id" style="vertical-align: middle;"></div>
            			</div>
            		</div>

              			<br />
              			<br />
              			<form action="/installer/restart_installer" method="post">
              				<input type="hidden" name="user_id" value="#{@user.id}" />
              				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
              				<input type="hidden" name="strap_id" value="#{@strap_id}" />
              				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
              			<span style="padding-left:30px">
              			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
              			</span>
              			</form>
                  	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
          eos
        render(:update) do |page|
          page.call('updateCheckHeartrate', false)
          page.replace_html('installer_div_id', str)
        end
      else
        p_count = progress_count(:heartrate)
        dts = dots(p_count)
        render(:update) do |page|
          page.replace_html('message_div_id', message)
          page.replace_html('duration_div_id', dts)
        end
      end
    else
      str = <<-eos

      <div id="lightbox-col-700">
     	<img src="/images/lightbox-col-header-700.gif" /><br />
     	<div class="lightbox-content-700">
          		<div style="width:600px;margin-left:auto;margin-right:auto" id="container">
          			<div id="installer_div_id">
            			<div id="message_div_id" style="font-size: 200%;vertical-align: middle;">#{battery_msg}</div>
            			<div id="duration_div_id" style="vertical-align: middle;"></div>
          			</div>
          		</div>

            			<br />
            			<br />
            			<form action="/installer/restart_installer" method="post">
            				<input type="hidden" name="user_id" value="#{@user.id}" />
            				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
            				<input type="hidden" name="strap_id" value="#{@strap_id}" />
            				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />
            				<span style="padding-left:30px">
            			<input type="submit" name="Restart Installation Wizard" value="Restart Installation Wizard">
            			</span>
            			</form>
                	</div><img src="/images/lightbox-col-footer-700.gif" /></div>
        eos
      render(:update) do |page|
        page.call('updateCheckHeartrate', false)
        page.replace_html('installer_div_id', str)
      end
    end
  end
  
  def range_test
    init_user_group
    init_devices_self_test_session
    @battery = Battery.find(:first, :conditions => "device_id = #{@strap.id} AND timestamp >= '#{@self_test_session.created_at.to_s}'", :order => 'timestamp desc')  
    str = <<-eos
    <div id="lightbox-col-700">
   	<img src="/images/lightbox-col-header-700.gif" /><br />
   	<div class="lightbox-content-700">
    <div style="width:600px;margin-left:auto;margin-right:auto" id="container">
		Please check the range in the following rooms and write down areas with one long beep (OUT of range). Consider using a cell phone with the senior as he or she walks around the home with the chest strap on.
			<br />
			<br />
			<ul>
				<li>Lying down in bed</li>
				<li>Stand in shower</li>
				<li>Kitchen</li>
				<li>Living room</li>
				<li>Other main activity areas</li>
			</ul>
			<br />
			<br />
			Your battery is at #{@battery.percentage if @battery }%. Please recharge if necessary before begining the Range Test.
			<br />
			<br />
			Two short beeps -- In Range
			<br />
			<br />
			One long beep   -- Out of Range
			<br />
			<br />
			<button onclick="javascript:start_range_test();">Start Range Test</button>
			<br/><br/>
			<a href="/installer/add_caregiver/?gateway_id=#{params[:gateway_id]}&self_test_session_id=#{params[:self_test_session_id]}&strap_id=#{params[:strap_id]}&user_id=#{params[:user_id]}">Skip range test (only for phone install)</a>
        	</div></div><img src="/images/lightbox-col-footer-700.gif" />
		</div>
    eos
  render(:update) do |page|
    page.replace_html('installer_div_id', str)
  end
  end
  
  def start_range_test
    init_user_group
    init_devices_self_test_session
    str = <<-eos
    <div id="lightbox-col-700">
   	<img src="/images/lightbox-col-header-700.gif" /><br />
   	<div class="lightbox-content-700">
      <div style="width:600px;margin-left:auto;margin-right:auto" id="container">
  		Please check the range in the following rooms and write down areas with one long beep (OUT of range). Consider using a cell phone with the senior as he or she walks around the home with the chest strap on.
  			<br />
  			<br />
  			<ul>
  				<li>Lying down in bed</li>
  				<li>Stand in shower</li>
  				<li>Kitchen</li>
  				<li>Living room</li>
  				<li>Other main activity areas</li>
  			</ul>
  			<br />
  			<br />
  			Two short beeps -- In Range
  			<br />
  			<br />
  			One long beep   -- Out of Range
  			<br />
  			<br />
  			Please enter out of range spots in home.
  			<br/>
  			<form action="/installer/stop_range_test" method="post") %>
  				<input type="hidden" name="user_id" value="#{@user.id}" />
  				<input type="hidden" name="gateway_id" value="#{@gateway_id}" />
  				<input type="hidden" name="strap_id" value="#{@strap_id}" />
  				<input type="hidden" name="self_test_session_id" value="#{@self_test_session_id}" />

  				<textarea id="notes_id" name="notes" rows="5" cols="32"></textarea>
  				<br />
  				<br />
  				<input type="submit" name="Stop Range Test" value="Stop Range Test" />
  			</form>
  			</div>
  			
          </div><img src="/images/lightbox-col-footer-700.gif" />
  	</div>
    eos
    create_self_test_step(START_RANGE_TEST_PROMPT_ID)
    create_mgmt_cmd('range_test_start', @strap.id)
    render(:update) do |page|
      page.replace_html('installer_div_id', str)
    end
  end
   
  def stop_range_test
    init_user_group
    init_devices_self_test_session
    create_mgmt_cmd('range_test_stop', @strap.id)
    self_test_step = create_self_test_step(RANGE_TEST_COMPLETE_ID)
      previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{HEARTRATE_DETECTED_ID}")
      message = self_test_step.self_test_step_description.description                       
    duration = nil
    unless previous_step
      previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{START_RANGE_TEST_PROMPT_ID}")
    end
    duration = self_test_step.timestamp - previous_step.timestamp
    create_mgmt_cmd('mgmt_poll_rate', @gateway.id, MGMT_POLL_RATE)
    create_self_test_step(SLOW_POLLING_MGMT_COMMAND_CREATED_ID)
    
    # render_update_success('range_test_div_id', message, nil, nil, 
    #                           'range_test_check', 'update_percentage', RANGE_TEST_PERCENTAGE, 
    #                           duration, 'notes', 'install_wizard_launch')
                          
    save_notes(@self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{RANGE_TEST_COMPLETE_ID}").id)
    
		redirect_to :action => 'add_caregiver', :user_id => @user_id, :group_name => @group_name,
		            :gateway_id => @gateway_id, :strap_id => @strap_id, :self_test_session_id => @self_test_session_id
  end
  
  def installer_complete
      init_user_group
      init_devices_self_test_session
      
      @self_test_session.completed_on = Time.now
      @self_test_session.save!
      clear_session_data
      session[:self_test_time_created] = Time.now
  end
  
  def timeout_notice
    init_user_group
    init_devices_self_test_session
    @message = params[:message]
    @self_test_step_id = params[:self_test_step_id]
    @self_test_result_id = params[:self_test_result_id]
    @self_test_result = SelfTestResult.find(@self_test_result_id) if !@self_test_result_id.blank?
    #clear_session_data
  end

  private

  def dots(count)
    dts = ''
    (0..count).each do |i|
        dts += '.'
    end
    return dts
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

  def init_user_group
    @user_id = params[:user_id]
    @user = User.find(@user_id)
    @group_name = params[:group_name]
    @group = Group.find_by_name(@group_name)
  end

  def init_devices_self_test_session
    @gateway_id = params[:gateway_id]
    @strap_id = params[:strap_id]
    @gateway = Device.find(@gateway_id)
    @strap = Device.find(@strap_id)
    @self_test_session_id = params[:self_test_session_id]
    @self_test_session = SelfTestSession.find(@self_test_session_id)
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
  
  def create_self_test_step(description_id)
    self_test_step_description = SelfTestStepDescription.find(description_id)    
    self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                                         :timestamp => Time.now.utc,
                                         :user_id => current_user.id, 
                                         :halo_user_id => @user.id,
                                         :self_test_session_id => @self_test_session_id)
    return self_test_step
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
  	@battery = Battery.find(:first, :conditions => "device_id = #{@strap.id} AND timestamp >= '#{@self_test_session.created_at.to_s}'", :order => 'timestamp desc')  
  
    if @battery && @battery.percentage <= 1
      return "Battery is at or less than 1% please recharge the battery."
    else
      return false
    end    
  end
  
  def check_registration_timeout?
    if Time.now > (session[:self_test_time_created] + INSTALL_WIZ_TIMEOUT_REGISTRATION)
      return true
    else 
      return false
    end
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
    :timestamp => Time.now.utc)   
    self_test_step = create_self_test_step(SELF_TEST_CHEST_STRAP_COMPLETE_ID)
    session[:halo_check_chest_strap_self_test] = self_test_step
    session[:halo_check_chest_strap_self_test_result] = @self_test
    return self_test_step
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
    
  def timeout?(self_test_step_description_id, seconds)
    step = @self_test_session.self_test_steps.find(:first,:conditions => "self_test_step_description_id = #{self_test_step_description_id}")
    if Time.now > (step.timestamp + seconds)
      return true
    else
      return false
    end
  end
  
  def check_gateway_timeout?
    timeout?(REGISTRATION_COMPLETE_ID, INSTALL_WIZ_TIMEOUT_GATEWAY)
  end
  
  def check_chest_strap_timeout?
    timeout?(SELF_TEST_GATEWAY_COMPLETE_ID, INSTALL_WIZ_TIMEOUT_CS)
  end
  
  def check_phone_timeout?
    timeout?(SELF_TEST_CHEST_STRAP_COMPLETE_ID, INSTALL_WIZ_TIMEOUT_PHONE)
  end
    
  def check_heartrate_timeout?
   if previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_PHONE_COMPLETE_ID}")
      timeout?(SELF_TEST_PHONE_COMPLETE_ID, INSTALL_WIZ_TIMEOUT_HEARTRATE)
    elsif previous_step = @self_test_session.self_test_steps.find(:first, :conditions => "self_test_step_description_id = #{SELF_TEST_PHONE_FAILED_ID}")
      timeout?(SELF_TEST_PHONE_FAILED_ID, INSTALL_WIZ_TIMEOUT_HEARTRATE)
    else
      timeout?(SELF_TEST_PHONE_TIMEOUT_ID, INSTALL_WIZ_TIMEOUT_HEARTRATE)
    end
  end
   
  def save_notes(step_id)
    self_test_step = SelfTestStep.find(step_id)
    self_test_step.notes = params[:notes]
    self_test_step.save!
  end
  
  def get_max_caregiver_position(user)
    get_caregivers(user)
    @caregivers.size + 1
  end
end