class UsersController < ApplicationController  
  def save_timezone
    user = User.find(current_user.id)
    user.profile.tz = tzinfo_from_timezone(TimeZone.new(params[:user][:timezone_name]))
    user.save
  end
  
  def tzinfo_from_timezone(timezone) 
    TZInfo::Timezone.all.each do |tz|
      if tz.current_period.utc_offset.to_i == timezone.utc_offset.to_i
        return tz
      end
    end
    return nil   
  end
  
  def new
    @user = User.new
    @gateway = Device.new
    @strap = Device.new
  end

  def create
    @user = User.new(params[:user])
    @gateway = nil
    @strap = nil
    #check if gateway exists
    if !params[:gateway][:serial_number].blank?
      @gateway = Device.find_by_serial_number(params[:gateway][:serial_number])
      if @gateway
        @user.devices << @gateway
      else
        @gateway = @user.devices.build(params[:gateway])
      end
    end
    
    #check is strap exists and if it is assigned to a user or not
    #could have been registered without assigning a user
    if !params[:strap][:serial_number].blank?
      @strap = Device.find_by_serial_number(params[:strap][:serial_number])
      if @strap && !@strap.users.blank?
        flash[:warning] = "Chest Strap with Serial Number #{params[:strap][:serial_number]} is already assigned to a user."
        throw Exception.new
      end
      if @strap
        @user.devices << @strap
      else
          @strap = @user.devices.build(params[:strap])          
      end
    end
    User.transaction do
        @user.save!
        
      # create profile
        Profile.create(:user_id => @user.id)
      
      # create halouser role
        @user.is_halouser
      
        @gateway.set_type
        @strap.set_type
      
      # register with strap/gateway
      #register_user_with_device(@user,@strap)
      #register_user_with_device(@user,@gateway)
    end
    #end
    #self.current_user = @user
    #redirect_back_or_default('/')
    #flash[:notice] = "Thanks for signing up!"
    #render :nothing => true
  rescue
    render :action => 'new'
  end
  
  def add_device_to_user    
    
    register_user_with_serial_num(User.find(params[:user_id]),params[:serial_number].strip)
    
    redirect_to :controller => 'reporting', :action => 'users'
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.activated?
      current_user.activate
      #flash[:notice] = "Signup complete!"
    end
    #redirect_back_or_default('/')
  end
  
  def init_caregiver
    @user = User.find_by_activation_code(params[:activation_code])
  end
  
  def update_caregiver
    @user = User.find_by_activation_code(params[:user][:activation_code])
    
    user_hash = params[:user]
    if user_hash[:password] == user_hash[:password_confirmation]
      if user_hash[:password].length >= 4
        @user.password = user_hash[:password]
        @user.password_confirmation = user_hash[:password_confirmation]
        @user.login = user_hash[:login]
        @user.save!
        self.current_user = @user
        if logged_in? && !current_user.activated?
          current_user.activate
        end
        redirect_to '/'
      else
        flash[:warning] = "Password must be at least 4 characters"
        render :action => 'init_caregiver'
      end
    else
        flash[:warning]= "New Password must equal Confirm Password"
        render :action => 'init_caregiver'
    end
    
  rescue
    render :action => 'init_caregiver'    
  end
  
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update_attributes!(params[:user])
        puts "look closer"
	
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])
    render :layout => false
  end  
  
  def ajax_edit
    @user = User.find(params[:id])
    render :layout => false
  end
  
  def redir_to_edit
    redirect_to '/users/'+params[:id]+';edit/'
  end
  
  def new_caregiver
    # get removed caregivers 
    
    @removed_caregivers = []
    
    current_user.caregivers.each do |caregiver|
      if caregiver
        caregiver.roles_users.each do |roles_user|
          if roles_user.roles_users_option and roles_user.roles_users_option[:removed]
            @removed_caregivers << caregiver
          end
        end 
      end
    end
    
    @max_position = get_max_caregiver_position(current_user)
    
    @password = random_password
    
    render :layout => false
  end
  
  def existing_info
    @user_info = User.find(params[:id])
    @user_cell_info = @user_info.profile.cell_phone
    @user_home_info = @user_info.profile.home_phone
    @user_carrier_id = @user_info.profile.carrier_id
    type = 'caregiver'
    if !params[:operator].blank?
      type = 'operator'
    end
    missing_what = nil

    if ("text" == params[:what])
      if (@user_cell_info == nil || @user_carrier_id == nil ||@user_cell_info == "" || @user_carrier_id == "" )
        missing_what = "The #{type} must include both a Cell Phone and Cell Carrier Provider. Would you like to enter both now?" 
      end
    end


    if ("phone" == params[:what])
     if ((@user_cell_info == "" or @user_cell_info == nil) and (@user_home_info == nil or @user_home_info == "" ))
         missing_what = "This #{type} must have either a Cell Phone or a Home Phone? Would you like enter one or both now?"
       end
    end
  render :partial => 'call_list/extra_info_lightbox', :locals => {:id => params[:id], :user_id => params[:user_id], :missing => missing_what} 
    
  end
  
  def create_caregiver
    @user = User.new(params[:user])
    if !@user.email.blank?
      if existing_user = User.find_by_email(@user.email)
        raise "Existing User"
      end
      
      @user.is_new_caregiver = true
      @user[:is_caregiver] =  true
      @user.save!
    
      profile = Profile.create(:user_id => @user.id)
    
      #patient = User.find(params[:user_id].to_i)
      patient = User.find(params[:user_id].to_i)
      role = @user.has_role 'caregiver', patient
      caregiver = @user
      @roles_user = patient.roles_user_by_caregiver(caregiver)
    
      update_from_position(params[:position], @roles_user.role_id, caregiver.id)
    
      RolesUsersOption.create(:roles_user_id => @roles_user.id, :position => params[:position], :active => 0)
    
   
      #redirect_to "/profiles/edit_caregiver_profile/#{profile.id}/?user_id=#{params[:user_id]}&roles_user_id=#{@roles_user.id}"
      UserMailer.deliver_caregiver_email(caregiver, patient)
      render :partial => 'caregiver_email'
    end
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn "#{e}"
    # check if email exists
    if existing_user = User.find_by_email(params[:user][:email])
      @existing_id = existing_user[:id]
      @add_existing = true
    end
   
  # old code without if else
   #render :partial => 'caregiver_form'
  
   #new code with if else and created a new partial existing_caregiver_form and removed <% if @add_existing %> function in  caregiver_form   
    @max_position = get_max_caregiver_position(@user)
     if (@add_existing == true )
         render :partial => 'existing_caregiver_form'
         else
         render :partial => 'caregiver_form'
    end
  end
  
  def destroy_operator
    RolesUsersOption.update(params[:id], {:removed => 1, :position => 0})
    @operators = User.operators
    number_ext
    render :layout =>false, :partial => 'call_center/operators'
  end
  
  def destroy_caregiver
    option = RolesUsersOption.find(params[:id])
    options = RolesUsersOption.find(:all, :conditions => "position > #{option.position} and roles_users.role_id = #{option.roles_user.role_id}", :include => :roles_user )
    
    options.each do |opt|
      opt.position-=1
      opt.save
    end
    RolesUsersOption.update(params[:id], {:removed => 1, :position => 0})
    render :layout =>false
  end
  
  def restore_caregiver_role
    user = User.find(params[:user_id])
    
    opt = RolesUsersOption.find(params[:id])
    opt.removed = false
    opt.position = get_max_caregiver_position(user)
    opt.save
    
    refresh_caregivers(user)
  end
  
  def add_existing
    @patient = User.find(params[:user_id])
    params[:patient_id] = params[:user_id]
    @caregiver = User.find(params[:id])
    
    role = @caregiver.has_role 'caregiver', @patient
    @roles_user = @patient.roles_user_by_caregiver(@caregiver)
    
    unless opt = RolesUsersOption.find(:first, :conditions => "roles_user_id = #{@roles_user.id}")
      opt = RolesUsersOption.create(:roles_user_id => @roles_user.id)
    end
    
    opt.active = true
    opt.position = get_max_caregiver_position(@patient)-1
    #opt.position = 1
    opt.removed = false
    opt.save
    
    refresh_caregivers(@patient)
  end
  
  def get_max_caregiver_position(user)
    get_caregivers(user)
    @caregivers.size + 1
  end
  
  def update_from_position(position, roles_user_id, user_id)
    caregivers = RolesUsersOption.find(:all, :conditions => "position >= #{position} and roles_user_id = #{roles_user_id}")
    
    caregivers.each do |caregiver|
      caregiver.position+=1
      caregiver.save
    end
  end
  
  def random_password
    Digest::SHA1.hexdigest("--#{Time.now.to_s}--")[0,6]
  end
  
  private
  def get_device_type(device)
    if(device.serial_number == nil)
      device_type = "Invalid serial num"
    elsif(device.serial_number.length != 10)
      device_type = "Invalid serial num"
    elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
      device_type = "Halo Chest Strap"
    elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
      device_type = "Halo Gateway"
    else
      device_type = "Unknown Device"
    end
    
    device_type
  end
  
  def register_user_with_serial_num(user, serial_number)
    unless device = Device.find_by_serial_number(serial_number)
      device = Device.new
      device.serial_number = serial_number
      device.device_type = get_device_type(device)
      device.save!
    end

    unless device.device_type
      device.device_type = get_device_type(device)      
    end
    device.users << user
    device.save!
  end
end
