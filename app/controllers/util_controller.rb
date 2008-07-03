class UtilController < ApplicationController
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
  
  def delete_panics
    Event.delete_all("event_type = 'Panic' and user_id = #{params[:id]}")
    Panic.delete_all("user_id = #{params[:id]}")
    redirect_to :controller => :events, :action => :user, :id => params[:id]
  end
  
  def send_test_email
    
  end
  
  def deliver_test_email
    email = CriticalMailer.deliver_test_email(params[:to], params[:subject], params[:body])
  end
  
end
