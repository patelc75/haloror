class UtilController < ApplicationController
  before_filter :authenticate_super_admin?, :except => ['check', 'hostname']
  #session :off
  
  # Monitors that the application and database connection is alive
  
  def check
    #if ServerInstance.is_task_server?
    ActiveRecord::Base.connection.select_value("select 1")
    #end
    
    # Neospire excpects this message. Please do NOT modify this.
    render :text => 'CONGRATULATIONS 200'
  end
  
  def info
    @alert_types = AlertType.find(:all)
    #render :text => request.host
    #render :text => request.env["HTTP_HOST"].to_s
  end
  
  def hostname
    render :layout => false
  end
  
  def home_install
    events_per_page = 25
    @users = User.paginate :page => params[:page], :order => "created_at DESC", :per_page => events_per_page
  end
  
  def delete_panics_and_falls
    Event.find(:all, :conditions => "(event_type = 'Fall' or event_type = 'Panic') and user_id = #{params[:id]}").each do |event|
      event.event_actions.each do |ea|
        EventAction.delete(ea.id)
      end 
      event.notes.each do |note|
        Note.delete(note.id)
      end
      event.class.delete(event.id)
    end
    redirect_to :controller => :events, :action => :user, :id => params[:id]
  end
  
  def send_test_email
    
  end
  
  def deliver_test_email
    email = CriticalMailer.deliver_test_email(params[:to], params[:subject], params[:body])
  end
  
  def signup_redirect
    log = AccessLog.new
    log.user_id = current_user.id
    log.status = 'logout'
    log.save
    
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_to "http://#{ServerInstance.current_host}/activate/caregiver/#{params[:id]}"
  end
  
  def google_health
    
  end
  
  def deliver_google_health_notice
    google = GoogleHealthClient.new
    auth = google.authenticate(params[:login], params[:password])
    id = google.profile_list(auth)
    
    vitals = Vital.find(:first, :conditions => "user_id = #{current_user.id}", :order => 'timestamp desc')
    @vitals_string = "#{vitals.timestamp}   HR: #{vitals.heartrate}    Activity: #{vitals.activity}"
    google.post_notice(auth, id, "Recent Vitals", @vitals_string)
  end 
end
