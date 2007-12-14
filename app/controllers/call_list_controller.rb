class CallListController < ApplicationController
  def show
    #layout :none	
    @call_list = User.find(params[:id])
    #render(:layout => false) # never use a layout
  end
  
  def sort
    @call_list = User.find(params[:id])
    @call_list.call_orders.each do |call_order|
      call_order.position = params['call_list'].index(call_order.id.to_s) + 1
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
  
  def move_up
     @call_list = User.find(params[:id])
     @call_list.call_orders.each do |call_order|
       call_order.position = params['call_list'].index(call_order.id.to_s) + 1
       call_order.save
     end

     render :action => show, :layout => false
  end
  
  def toggle_phone
    @call_order = CallOrder.find(params[:id])

    if @call_order.phone_active == 0
      @call_order.phone_active = 1
    else
      @call_order.phone_active = 0
    end
    
    @call_order.save
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def toggle_email
    @call_order = CallOrder.find(params[:id])

    if @call_order.email_active == 0
      @call_order.email_active = 1
    else
      @call_order.email_active = 0
    end
    
    @call_order.save
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def toggle_text
    @call_order = CallOrder.find(params[:id])

    if @call_order.text_active == 0
      @call_order.text_active = 1
    else
      @call_order.text_active = 0
    end
    
    @call_order.save
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def activate
    @call_order = CallOrder.find(params[:id])
    @call_order.active = 1
    
    @call_order.save
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def deactivate
    @call_order = CallOrder.find(params[:id])
    @call_order.active = 0
    
    @call_order.save
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
end
