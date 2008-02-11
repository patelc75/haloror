class CallListController < ApplicationController
  def show
    unless logged_in?
      redirect_to '/login'
    else
      @call_list = User.find(params[:id])
      number_ext
    end
    
    @user = User.find(1)
    
    get_caregivers
  end
  
  def get_caregivers
    # loop through assigned roles, check for removed = 1
    
    @caregivers = {}
    
    current_user.has_caregivers.each do |caregiver|
      unless caregiver.roles_users_option.removed
        @caregivers[caregiver.roles_users_option.position] = caregiver
      end
    end
    
    @caregivers.sort
  end
  
  def sort
    get_caregivers
    
    @caregivers.each do |position, caregiver|
      opts = caregiver.roles_users_option
      opts.position = params['call_list'].index(opts.user_id.to_s) + 1
      opts.save
    end

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
    opts = RolesUsersOption.find(params[:id])

    if !opts.phone_active
      state = 1
    else
      state = 0
    end
    
    RolesUsersOption.update(params[:id], {:phone_active => state})
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def toggle_email
    opts = RolesUsersOption.find(params[:id])

    if !opts.email_active
      state = 1
    else
      state = 0
    end
    
    RolesUsersOption.update(params[:id], {:email_active => state})
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def toggle_text
    opts = RolesUsersOption.find(params[:id])

    if !opts.text_active
      state = 1
    else
      state = 0
    end
    
    RolesUsersOption.update(params[:id], {:text_active => state})
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def activate
    RolesUsersOption.update(params[:id], {:active => 1})

    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def deactivate
    RolesUsersOption.update(params[:id], {:active => 0})
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def set_caregiver_first_name
    User.update(params[:id], {:first_name => params[:value]})
    
    @name = params[:value]
    
    render :layout => false, :inline => "<%= @name %>"
  end
  
  def set_caregiver_last_name
    User.update(params[:id], {:last_name => params[:value]})
    
    @name = params[:value]
    
    render :layout => false, :inline => "<%= @name %>"
  end
end
