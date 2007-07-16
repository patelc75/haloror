# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
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
end
