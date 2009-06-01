class UsersController < ApplicationController  
  before_filter :authenticated?, :except => [:init_user, :update_user]
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
    @profile = Profile.new
    @groups = []
    gs = current_user.group_memberships
    gs.each do |g|
      @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
    end
  end

  def create
    
      @user = User.new(params[:user])
      @user.email = params[:email]
      @group = params[:group]
      @profile = Profile.new(params[:profile])
    if !@group.blank? && @group != 'Choose a Group'
  
      User.transaction do
          @user[:is_new_user] = true
          if @user.save
            # create profile
            @profile.user_id = @user.id
            if @profile.save
          
            else
              raise "Invalid Profile"  
            end
            # create halouser role
            @user.is_halouser_of Group.find_by_name(@group)
            if(current_user.is_super_admin? || current_user.is_admin_of_any?(@user.group_memberships))
              if(params[:opt_out_call_center].blank?)
                @user.is_halouser_of Group.find_by_name('SafetyCare')
              end
            end
          else
            raise "Invalid User"
          end
      end
    else 
      flash[:warning] = "Group is Required"
      redirect_to :controller => 'users', :action => 'new'
    end
  rescue Exception => e
    RAILS_DEFAULT_LOGGER.warn("ERROR signing up, #{e}")
     @groups = []
      gs = current_user.group_memberships
      gs.each do |g|
        @groups << g if(current_user.is_sales_of?(g) || current_user.is_admin_of?(g) || current_user.is_super_admin?)
      end
    render :action => 'new'
  end
  
  def signup_details
  	@user = User.find params[:id]
  	@alert_types = []
  	AlertType.find(:all).each do |type|    
      @alert_types << type        
    end
  end
  
  def add_device_to_user    
    if valid_serial_number(params[:serial_number])
    	register_user_with_serial_num(User.find(params[:user_id]),params[:serial_number].strip)
    else
    	flash[:notice] = "Not Valid Serial Number, Serial number must be exactly 10 digits."
    end
    	redirect_to :controller => 'reporting', :action => 'users'
  end
  
  def valid_serial_number(serial_number)
  	if serial_number.length != 10
  		return false	
  	else
  		return true
  	end
  end
  
  def activate
    user = User.find_by_activation_code(params[:activation_code])
    if !user.activated?
      user.activate
      #flash[:notice] = "Signup complete!"
    end
    #redirect_back_or_default('/')
  end
  
  def init_user
    @user = User.find_by_activation_code(params[:activation_code])
  end
  
  def update_user
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
        current_user.set_active()
        if current_user.is_caregiver?
          redirect_to :controller => 'call_list', :action => 'show', :recently_activated => 'true'
        else
          redirect_to '/'
        end
      else
        flash[:warning] = "Password must be at least 4 characters"
        render :action => 'init_user'
      end
    else
        flash[:warning]= "New Password must equal Confirm Password"
        render :action => 'init_user'
    end
    
  rescue
    render :action => 'init_user'    
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
  def refresh
    @user = User.find(params[:user_id])
    refresh_caregivers(@user)
  end
  def create_caregiver
    @user = User.new(params[:user])
    
    if !@user.email.blank?
      # if existing_user = User.find_by_email(@user.email)
      #         raise "Existing User"
      #       end
      
     User.transaction do  
      @user.is_new_caregiver = true
      @user[:is_caregiver] =  true
      @user.save!
      profile = Profile.new(:user_id => @user.id)
      profile[:is_new_caregiver] = true
      profile.save!
    
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
#  def get_device_type(device)
#    if(device.serial_number == nil)
#      device_type = "Invalid serial num"
#    elsif(device.serial_number.length != 10)
#      device_type = "Invalid serial num"
#    elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
#      device_type = "Halo Chest Strap"
#    elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
#      device_type = "Halo Gateway"
#    else
#      device_type = "Unknown Device"
#    end
#    
#    device_type
#  end
  
  def register_user_with_serial_num(user, serial_number)
    unless device = Device.find_by_serial_number(serial_number)
      device = Device.new
      device.serial_number = serial_number
      # if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
      #         device.set_chest_strap_type
      #       elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
      #         device.set_gateway_type
      #       end
      device.save!
    end

    if device.device_type.blank?
      if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
        device.set_chest_strap_type
      elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
        device.set_gateway_type
      end   
    end
    device.users << user
    device.save!
  end
end
