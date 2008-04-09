class UsersController < ApplicationController
  include UsersHelper

  before_filter:set_user
  
  def set_user
    UsersHelper.current_host = request.host
  end

  def choose_timezone
    
  end
  
  def save_timezone
    user = User.find(current_user.id)
    user.tz = tzinfo_from_timezone(TimeZone.new(params[:user][:timezone_name]))
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
    #render :layout => false
  end

  def create
    @user = User.new(params[:user])
    User.transaction do
      @user.save!
        
      # create profile
      Profile.create(:user_id => @user.id)
      
      # register with strap/gateway
      

      @strap = register_user_with_device(@user,params[:strap_serial_number])
      @gateway = register_user_with_device(@user,params[:gateway_serial_number])
    end
    #end
    #self.current_user = @user
    #redirect_back_or_default('/')
    #flash[:notice] = "Thanks for signing up!"
    #render :nothing => true
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def add_device_to_user    
    register_user_with_device(User.find(params[:user_id]),params[:serial_number])
    
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
    
    current_user.has_caregivers.each do |caregiver|
      user = User.find(caregiver.user_id)
      if user and user.roles_users_option and user.roles_users_option[:removed]
        @removed_caregivers << caregiver
      end
    end
    
    @max_position = get_max_caregiver_position
    
    @password = random_password
    
    render :layout => false
  end
  
  def existing_info
    render :partial => 'call_list/extra_info_lightbox', :locals => {:caregiver_id => params[:id]}
  end
  
  def create_caregiver
    @user = User.new(params[:user])
    @user.save!
    
    profile = Profile.create(:user_id => @user.id)
    
    role = @user.has_role 'caregiver', current_user
    @role = @user.roles_user
    
    update_from_position(params[:position], @role.role_id, @user.id)
    
    RolesUsersOption.create(:roles_users_id => @role.id, :user_id => @user.id, :position => params[:position], :active => 1)
    


    redirect_to :controller => 'profiles', :action => 'edit_caregiver_profile', :id => profile.id
  rescue ActiveRecord::RecordInvalid
    # check if email exists
    if @existing_id = User.find_by_email(params[:user][:email]).id
      @add_existing = true
    end
    
    @max_position = get_max_caregiver_position
    render :partial => 'caregiver_form'
  end
  
  def destroy_caregiver
    RolesUsersOption.update(params[:id], {:removed => 1})
    
    render :layout =>false
  end
  
  def restore_caregiver_role
    RolesUsersOption.update(params[:id], {:removed => 0})
    
    refresh_caregivers
  end
  
  def add_existing
    @user = User.find(params[:id])
    
    role = @user.has_role 'caregiver', current_user
    @role = @user.roles_user
    
    RolesUsersOption.create(:roles_users_id => @role.id, :user_id => @user.id, :position => current_user.has_caregivers.length, :active => 1)
    refresh_caregivers
  end
  
  def get_max_caregiver_position
    get_caregivers
    @caregivers.size + 1
  end
  
  def update_from_position(position, roles_user_id, user_id)
    caregivers = RolesUsersOption.find(:all, :conditions => "position >= #{position} and roles_users_id = #{roles_user_id} and user_id = #{user_id}")
    
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
  
  def register_user_with_device(user, serial_number)
    unless device = Device.find_by_serial_number(serial_number)
      device = Device.new
      device.serial_number = serial_number
      device.device_type = get_device_type(device)
      device.save!
    end

    device.users << user
    device.save!
  end
end
