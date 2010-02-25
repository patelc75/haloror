# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  audit User, Profile, RolesUsersOption, AlertOption
  
  include ServerInstance
  include AuthenticatedSystem
  include ExceptionNotifiable
  rescue_from RuntimeError, :with => 'error'
  local_addresses.clear # always send email notifications instead of displaying the error  
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_HaloRoR2_session_id'  

  filter_parameter_logging :card_number
  
  #This method is needed because of the way attachment_fu stores the files 
  #uploaded on the file system.  attachment_fu stores the files in a folder with 
  #the same name as the model within the public folder.  This causes issues 
  #since the url for the controller, as well as the directory for storing files 
  #have the same URL. 
  def default_url_options(options)
    { :trailing_slash => true }
  end
  
  before_filter do |c|
    User.current_user = User.find(c.session[:user]) unless c.session[:user].nil?
  end
  
  before_filter :authenticated?
  before_filter :set_host
  before_filter :set_user_time_zone

  def error(exception)
    render :controller => 'errors', :action => 'error'
  end
  
  def set_host
    ServerInstance.current_host = request.host
  end
  
  def number_ext
    @num_ref = {}
    @num_ref[0] = 'th'
    @num_ref[1] = 'st'
    @num_ref[2] = 'nd'
    @num_ref[3] = 'rd'
    @num_ref[4] = 'th'
    @num_ref[5] = 'th'
    @num_ref[6] = 'th'
    @num_ref[7] = 'th'
    @num_ref[8] = 'th'
    @num_ref[9] = 'th'
  end
  
  private
  def refresh_operators(group_id=nil)
    @user = current_user
    @groups = []
      if !@user.is_super_admin?
        @groups = Group.find(:all)
      else
        Group.find(:all).each do |g|
          @groups << g if(@user.is_operator_of?(g) || @user.is_moderator_of?(g) || @user.is_admin_of?(g))
        end
      end 
    if group_id.blank?
      @group = @groups[0]
    else
      g = Group.find(group_id)
      @group = g if @groups.include? g
    end
    @operators = []
    ops = User.operators
    ops.each do |op|
      @operators << op if(op.is_operator_of?(@group))
    end
    number_ext
    render :partial => 'call_center/operators', :layout => false
  end
  def refresh_caregivers(user)
    number_ext
    
    # loop through assigned roles, check for removed = 1
    
    get_caregivers(user)
    
    render :layout => false, :partial => 'call_list/load_caregivers', :locals => {:caregivers => @caregivers,:user => user}
  end
  
  def get_caregivers(user)    
    @user = user
    @caregivers = user.caregivers_sorted_by_position
  end

  private

  def set_user_time_zone
    if logged_in? && !current_user.profile.blank?
      Time.zone = current_user.profile.time_zone
    else
      Time.zone = 'Central Time (US & Canada)'
    end
  end

  protected
  def authenticated?
    unless (controller_name == 'users' && (action_name == 'init_caregiver' || action_name == 'update_caregiver' || action_name == 'activate') || 
      controller_name == 'sessions' ||
      controller_name == 'errors'  || 
      controller_name == 'flex' && action_name == 'chart' || 
      controller_name == 'util' && action_name == 'check' ||
      controller_name == 'util' && action_name == 'hostname' ||
      controller_name == 'util' && action_name == 'version' ||
      controller_name == 'util' && action_name == 'terms' ||
      controller_name == 'util' && action_name == 'privacy' ||
      controller_name == 'util' && action_name == 'support' ||
      controller_name == 'healthvault' && action_name == 'redirect' ||      
      controller_name == 'security') ||
      controller_name == 'orders' && ['new','create','show'].include?(action_name) # we will create user here
      return authenticate
    else
      return true
    end
  end
  def authenticate
    unless logged_in?
      store_location
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_super_admin?
    unless logged_in? && (current_user.is_super_admin?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_halouser?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_halouser?)
      return redirect_to('/login')
    end
    true
  end
  def authenticate_admin_caregiver?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_caregiver?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_halouser_caregiver?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_halouser? || current_user.is_caregiver?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_halouser_caregiver_operator?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_halouser? || current_user.is_caregiver? || current_user.is_operator?)
      return redirect_to('/login')
    end
    true
  end
  def authenticate_admin_halouser_caregiver_operator_sales?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_halouser? || current_user.is_caregiver? || current_user.is_operator? || current_user.is_sales?)
      return redirect_to('/login')
    end
    true
  end
  def authenticate_admin_halouser_caregiver_operator_sales_installer?
    debugger
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_halouser? || current_user.is_caregiver? || current_user.is_operator? || current_user.is_sales? || current_user.is_installer?)
      return redirect_to('/login')
    end
    true
  end
  def authenticate_admin_operator?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_operator?)
      return redirect_to('/login')
    end
    true
  end
  
  
  def authenticate_admin_operator_moderator?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_operator? || current_user.is_moderator?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_sales?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_sales?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_moderator?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_moderator?)
      return redirect_to('/login')
    end
    true
  end
  def authenticate_admin?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_installer?
  	unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_installer?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_moderator_installer?
  	unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_operator? || current_user.is_installer?)
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin_halouser_caregiver_sales?
    unless logged_in? && (current_user.is_admin? || current_user.is_super_admin? || current_user.is_halouser? || current_user.is_caregiver? || current_user.is_sales?)
      return redirect_to('/login')
    end
    true
  end
  
  # collect activerecord errors using add_to_base
  # required only for procedural progamming used in user, user_intake etc
  #
  def collect_active_record_errors(collect_here, names_to_collect_from = [])
    if collect_here.is_a? ActiveRecord::Base # forget otherwise
      #
		  # = Add errors and validation to activerecord
		  # example: add errors from @profile and @user objects to @user_intake
		  # Errors will be added only for variables that exist right now
		  #   errors may be caused by activerecord validations of these objects using save!
		  #   this will show proper validation errors on the form
		  #
	    names_to_collect_from.each do |obj_name|
	      obj = eval("@#{obj_name}")
        #
        # variable does not exist? or not AR? add a general validation error
        if obj.blank? || !obj.is_a?(ActiveRecord::Base)
          collect_here.errors.add_to_base "#{obj_name} data is not appropriate. Please notify the administrator if you have filled the profile correctly but see this error."
        else
          #
          # variable exists? is AR?, add specific validation errors
          obj.errors.each_full { |e| collect_here.errors.add_to_base e } unless obj.errors.count.zero?
        end
      end # each
    end # only collect when AR
  end

end
