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
    #render :text => request.host
    #render :text => request.env["HTTP_HOST"].to_s
  end
end
