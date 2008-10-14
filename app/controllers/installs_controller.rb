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
    MgmtCmd.create(:cmd_type            => 'self_test', 
                     :device_id           => @strap.id, 
                     :user_id             => @user.id,
                     :creator             => current_user,
                     :originator          => 'server',
                     :pending             => true,
                     :pending_on_ack      => true,                     
                     :timestamp_initiated => now)
    
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
    @user = User.find(params[:user_id])
    @gateway = Device.find(params[:gateway_id])
    @strap = Device.find(params[:strap_id])
  end
  
  def install_wizard_progress
    gateway_id = params[:gateway_id]
    strap_id = params[:strap_id]
    user = User.find(params[:user_id])
    text = 'Registering...'
    message = ''
    percentage = 0
    self_test_step = nil
    if(self_test_step = check_phone_self_test(user, gateway_id))
      percentage = 100
      text = self_test_step.self_test_step_description.description
      message = launch_remote_redbox(:url =>{ :controller => "installs", :action => 'self_test_complete'}, :html => {:method => :get, :complete => ''})
#      "Installation Successful!<br />  Press 'Finish' to Complete.<br /><br /><form action=\"/installs/finish\" method=\"POST\"><input type=\"submit\" name=\"Finish\" value=\"Finish\" /></form>"
    elsif(self_test_step = check_chest_strap_self_test(user, strap_id))
      percentage = 60
      text = self_test_step.self_test_step_description.description
    elsif(self_test_step = check_gateway_self_test(user, gateway_id))
      percentage = 40
      text = self_test_step.self_test_step_description.description
    elsif(self_test_step = check_registered(user, gateway_id, strap_id))
      percentage = 20
      text = self_test_step.self_test_step_description.description
    end
    checked = "/images/checkbox.png"
    render(:update) do |page| 
      page.call('update_percentage', percentage)
      page.replace_html 'install_wizard_status', text
      if(percentage == 100)
        page['registered_check'].src = checked
        page['self_test_gateway_check'].src = checked
        page['self_test_chest_strap_check'].src = checked
        page['self_test_phone_check'].src = checked
        message = launch_remote_redbox(:url =>{ :controller => "installs", :action => 'self_test_complete'}, :html => {:method => :get, :complete => ''})
      elsif(percentage == 60)
        page['registered_check'].src = checked
        page['self_test_gateway_check'].src = checked
        page['self_test_chest_strap_check'].src = checked
        if @self_test && !@self_test.result
          message = "Phone self test failed."
        end
      elsif(percentage == 40)
        page['registered_check'].src = checked
        page['self_test_gateway_check'].src = checked
        if @self_test && !@self_test.result
          message = "Self test failed on Halo Chest Strap."
        end        
      elsif(percentage == 20)
        page['registered_check'].src = checked 
        if @self_test && !@self_test.result
          message = "Self test failed on Halo Gateway."
        end   
      end
      page.replace_html 'install_wizard_result', message
    end
  end
  
  def self_test_complete
    
  end
  
  private
  def check_phone_self_test(user, gateway_id)
    yesterday = 1.day.ago
    if(!session[:halo_check_phone_self_test])
      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test_phone' AND result = true AND timestamp > '#{yesterday.to_s}'")
      if @self_test
        self_test_step_description = SelfTestStepDescription.find(4)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => user.id)
        session[:halo_check_phone_self_test] = self_test_step
        return self_test_step
      else
        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test_phone' AND result = false AND timestamp > '#{yesterday.to_s}'")        
        return false
      end
    else
      return session[:halo_check_phone_self_test]
    end
  end
  
  def check_chest_strap_self_test(user, strap_id)
    yesterday = 1.day.ago
    if(!session[:halo_check_chest_strap_self_test])
      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{strap_id} AND cmd_type = 'self_test' AND result = true AND timestamp > '#{yesterday.to_s}'")
      if @self_test
        self_test_step_description = SelfTestStepDescription.find(3)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => user.id)
        session[:halo_check_chest_strap_self_test] = self_test_step
        return self_test_step
      else
        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{strap_id} AND cmd_type = 'self_test' AND result = false AND timestamp > '#{yesterday.to_s}'")
        return false
      end
    else
      return session[:halo_check_chest_strap_self_test]
    end
  end
  
  def check_gateway_self_test(user, gateway_id)
    yesterday = 1.day.ago
    if(!session[:halo_check_gateway_self_test])
      @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test' AND result = true AND timestamp > '#{yesterday.to_s}'")
      if @self_test
        self_test_step_description = SelfTestStepDescription.find(2)    
        self_test_step = SelfTestStep.create(:self_test_step_description_id => self_test_step_description.id,
                          :timestamp => Time.now,
                          :user_id => current_user.id, 
                          :halo_user_id => user.id)
        session[:halo_check_gateway_self_test] = self_test_step
        return self_test_step
      else
        @self_test = SelfTestResult.find(:first, :conditions => "device_id = #{gateway_id} AND cmd_type = 'self_test' AND result = false AND timestamp > '#{yesterday.to_s}'")
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
        self_test_step_description = SelfTestStepDescription.find(1)    
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