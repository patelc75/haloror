class BatteriesController < RestfulAuthController
  
  
  def device
    #@device = Device.find(params[:id])
    render :layout => 'application'
  end
  
  def chart_data
    device = Device.find(params[:id])
    
    @readings = device.batteries
    
    # @readings = {}
    #     
    #     device.batteries.each do |reading|
    #       #date = reading.timestamp.to_date.to_s(:db)
    #       date = reading.timestamp.to_s
    #       
    #       @readings[date] = []
    #       @readings[date] = reading
    #     end
    
    render :layout => false
    
    # User.find(params[:id]).access_logs.each do |log|
    #       date = log.created_at.to_date.to_s(:db)
    #       #date = date[0]
    #       
    #       unless @logs[date]
    #         @logs[date] = {:successful => 0, :failed => 0}
    #       end
    #       
    #       if log.status == 'successful'
    #         @logs[date][:successful] += 1
    #       elsif log.status == 'failed'
    #         @logs[date][:failed] += 1
    #       end      
    #     end
  end
end
