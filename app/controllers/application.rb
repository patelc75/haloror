# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

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
  
  def refresh_caregivers
    number_ext
    
    # loop through assigned roles, check for removed = 1
    
    caregivers = []
    
    current_user.has_caregivers.each do |caregiver|
      unless caregiver.roles_users_option.removed
        caregivers.push(caregiver)
      end
    end
    
    render :layout => false, :partial => 'call_list/load_caregivers', :locals => {:caregivers => caregivers}
  end
  
  def get_caregivers
    # loop through assigned roles, check for removed = 1
    
    @caregivers = {}
    
    current_user.has_caregivers.each do |caregiver|
      unless caregiver.roles_users_option.removed
        @caregivers[caregiver.roles_users_option.position] = caregiver
      end
    end
    
    @caregivers.sort
  end
end
