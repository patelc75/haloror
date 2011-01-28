# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# # 
# #  Sat Jan 15 00:27:37 IST 2011, ramonrails
# #   * profiling the code, made easier
# require "ruby-prof"

class ApplicationController < ActionController::Base
  # 
  #  Tue Jan 25 20:45:46 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4074
  audit User, Profile, RolesUsersOption, AlertOption, Invoice#, UserIntake
  
  include ServerInstance
  include AuthenticatedSystem
  include ExceptionNotifiable
  rescue_from RuntimeError, :with => 'error'
  local_addresses.clear # always send email notifications instead of displaying the error  
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_HaloRoR2_session_id'  

  # 
  #  Tue Nov  9 21:39:39 IST 2010, ramonrails
  #  Never allow these to go into logs, even on production
  filter_parameter_logging :card_number, :cvv, :password, :password_confirmation
  
  # # 
  # #  Sat Jan 15 00:27:53 IST 2011, ramonrails
  # #   * around filter for profiling the code
  # around_filter :profile

  # ==================
  # = public methods =
  # ==================
  
  # # 
  # #  Sat Jan 15 00:28:25 IST 2011, ramonrails
  # #   * profiling the code
  # def profile
  #   if (params[:profile].nil? || (RAILS_ENV != 'development'))
  #     yield
  #   else
  #     result = RubyProf.profile { yield }
  #     printer = RubyProf::GraphPrinter.new(result)
  #     out = StringIO.new
  #     printer.print(out, 0)
  #     response.body.replace out.string
  #     response.content_type = "text/plain"
  #  end
  # end
  
  # TODO: need some work before it can run flawless
  # # ramonrails: auto-assign created_by, updated_by only if the columns exist
  # before_filter :set_current_user
  # 
  # # ramonrails: auto-assign created_by, updated_by only if the columns exist
  # def set_current_user
  #   Thread.current['user'] = session[:user]
  # end

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
  after_filter :discard_flash_if_xhr # usually happens on visiting another action. AJAX calls require to force discard it

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
  
  # ===================
  # = private methods =
  # ===================
  
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

  def set_user_time_zone
    if logged_in? && !current_user.profile.blank?
      # 
      #  Wed Nov 24 01:32:51 IST 2010, ramonrails
      #   * # this will default to UTC, as defined in environment.rb
      #   * https://redmine.corp.halomonitor.com/issues/3771
      Time.zone = current_user.profile.time_zone || 'Central Time (US & Canada)' # just in case
    else
      #   * When not logged in, assume to be in Central Time Zone
      Time.zone = 'Central Time (US & Canada)'
    end
  end

  # =====================
  # = protected methods =
  # =====================

  protected
  
  # 
  #  Wed Dec 22 00:17:00 IST 2010, ramonrails
  #   * flash for AJAX. must be discarded
  #   * flash usually gets discarded when another action is visited
  def discard_flash_if_xhr
    flash.discard if request.xhr?
  end

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
      (controller_name == 'orders' && ['new','create','show', 'kit_serial', 'update_kit_serial', 'agreement', 'success', 'failure'].include?(action_name)) || # we will create user here
      (controller_name == 'alerts' && action_name == 'alert')
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
  def collect_active_record_errors(collect_here, valid_and_not_blank_objects = [], blank_or_valid_objects = [])
    if collect_here.is_a? ActiveRecord::Base # forget otherwise
      #
		  # = Add errors and validation to activerecord
		  # example: add errors from @profile and @user objects to @user_intake
		  # Errors will be added only for variables that exist right now
		  #   errors may be caused by activerecord validations of these objects using save!
		  #   this will show proper validation errors on the form
		  #
	    valid_and_not_blank_objects.each do |obj_name|
	      obj = eval("@#{obj_name}")
        #
        # variable does not exist? or not AR? add a general validation error
        if obj.blank? || !obj.is_a?(ActiveRecord::Base)
          collect_here.errors.add_to_base "#{obj_name} data is not appropriate. Please notify the administrator if you have filled the profile correctly but see this error."
        else
          obj.errors.each_full { |e| collect_here.errors.add_to_base e } unless obj.errors.count.zero?
        end
      end # each
      
      blank_or_valid_objects.each do |obj_name|
	      obj = eval("@#{obj_name}")
	      unless obj.blank?
          if !obj.is_a?(ActiveRecord::Base)
            collect_here.errors.add_to_base "#{obj_name} data is not appropriate. Please notify the administrator if you have filled the profile correctly but see this error."
          else
            obj.errors.each_full { |e| collect_here.errors.add_to_base e } unless obj.errors.count.zero?
          end
        end
      end # each
	    
    end # only collect when AR
  end

  # redirect to message page, back to the calling page
  def redirect_to_message(options)
    {:message => ALERT_MESSAGES[:default], :back_url => nil, :template => nil}.merge(options)
    unless options[:back_url].blank?
      session[:alert_phrase] = (options[:message].is_a?(Symbol) ? ALERT_MESSAGES[options[:message]] : options[:message])
      session[:alert_back_url] = options[:back_url] # blank will take to appropriate home page
      session[:alert_template] = options[:template] # we can render a template or message
      logger.debug "redirecting to alerts -- #{session[:alert_back_url]} -- #{session[:alert_phrase]}"
      if options[:template].blank?
        redirect_to :controller => "alerts", :action => "alert"
      else
        redirect_to options[:template]
      end
    end
  end

end
