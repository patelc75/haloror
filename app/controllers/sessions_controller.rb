# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  include ApplicationHelper
  
  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    
    if logged_in?
      log = AccessLog.new
      log.user_id = current_user.id
      log.status = 'successful'
      log.save
      
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , 
								 :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      log = AccessLog.new
      
      if user = User.find_by_login(params[:login])
        log.user_id = user.id
      end

      log.status = 'failed'
      log.save
    
     # @show_redbox = true     
    # render :action => 'new'
      redirect_to_message(:message => :login_failed, :back_url => url_for(:controller => "sessions", :action => "new"))
      # redirect_to :controller => "alerts", :action => "alert"
    end
  end
 
  def failure
    render :partial => 'failure'
  end
  
  def destroy
    log = AccessLog.new
    log.user_id = current_user # TODO: Object.id is deprecated. Maybe change logic here to log differently
    log.status = 'logout'
    log.save
    
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
  
end
