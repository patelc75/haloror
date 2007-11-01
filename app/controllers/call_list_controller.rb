class CallListController < ApplicationController
  def show
    #layout :none	
    @call_list = User.find(params[:id])
    render(:layout => false) # never use a layout
  end
  
  def sort
    @call_list = User.find(params[:id])
    @call_list.call_orders.each do |call_order|
      call_order.position = params['call-list'].index(call_order.id.to_s) + 1
      call_order.save
    end

    render :action => show, :layout => false
  end
  
  def text
    @caregiver = Caregiver.new
    logger.info("CallListController::text")
    render(:layout => false)	
  end
  
  def add_caregiver
    if @caregiver = Caregiver.new(params[:caregiver])
      @caregiver.save
    end
	
	#render :nothing => true
	render(:layout => false)	

  end
end
