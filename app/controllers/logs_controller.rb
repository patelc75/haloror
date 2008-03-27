class LogsController < ApplicationController
  def user
    @logs = User.find(params[:id]).access_logs
  end
  
  def chart_data
    @logs = {}
    
    User.find(params[:id]).access_logs.each do |log|
      date = log.created_at.to_date.to_s(:db)
      #date = date[0]
      
      unless @logs[date]
        @logs[date] = {:successful => 0, :failed => 0}
      end
      
      if log.status == 'successful'
        @logs[date][:successful] += 1
      elsif log.status == 'failed'
        @logs[date][:failed] += 1
      end      
    end
    
    render :layout => false
  end
end
