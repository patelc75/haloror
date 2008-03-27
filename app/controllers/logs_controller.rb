class LogsController < ApplicationController
  def user
    @logs = User.find(params[:id]).access_logs
  end
  
  def chart_data
    @logs = {}
    
    User.find(params[:id]).access_logs.each do |log|
      unless @logs[log.created_at]
        @logs[log.created_at] = {:successful => 0, :failed => 0}
      end
      
      if log.status == 'successful'
        @logs[log.created_at][:successful] += 1
      elsif log.status == 'failed'
        @logs[log.created_at][:failed] += 1
      end      
    end
    
    render :layout => false
  end
end
