# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ServerInstance
  include AuthenticatedSystem
  include ExceptionNotifiable
  
  local_addresses.clear # always send email notifications instead of displaying the error  
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_HaloRoR2_session_id'  
  
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
  before_filter:set_host
  
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
  def refresh_operators()
    @operators = User.operators
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
  
  protected
  def authenticated?
    unless (controller_name == 'users' && (action_name == 'init_caregiver' || action_name == 'update_caregiver' || action_name == 'new' || action_name == 'create' || action_name == 'activate') || 
      controller_name == 'sessions' || 
      controller_name == 'flex' && action_name == 'chart' || 
      controller_name == 'util' && action_name == 'check' ||
      controller_name == 'util' && action_name == 'hostname' ||
      controller_name == 'security')
      return authenticate
    else
      return true
    end
  end
  def authenticate
    unless logged_in?
      return redirect_to('/login')
    end
    true
  end
  
  def authenticate_admin
    unless logged_in? && current_user.is_administrator?
      return redirect_to('/login')
    end
    true
  end
end
