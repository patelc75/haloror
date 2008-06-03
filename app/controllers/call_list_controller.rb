class CallListController < ApplicationController

  before_filter :authenticate, :only => 'show'

  def show
    @call_list = User.find(params[:id])
    number_ext
    #@user = User.find(1)
    
    if params[:id]
      user = User.find(params[:id])
    else
      user = current_user
    end
    
    get_caregivers(user)
  end
  
  def sort
    get_caregivers(User.find(params[:user_id]))
    
    @caregivers.each do |position, caregiver|
      opts = current_user.roles_user_by_caregiver(caregiver)		
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
  
  def toggle_critical(what, roles_user_id)
    opts = RolesUsersOption.find_by_roles_user_id(roles_user_id)
    orig_opts = opts
    column = "#{what}_active"
    
    if !opts[column.to_sym]
      state = 1
    else
      state = 0
    end
    
    opts[column.to_sym] = state
    opts.save
    
    #RolesUsersOption.update(params[:id], {column.to_sym => state})
    
    AlertGroup.find_by_group_type('critical').alert_types.each do |alert_type|
      unless alert_opt = AlertOption.find(:first, :conditions => "roles_user_id = #{roles_user_id} and alert_type_id = #{alert_type.id}")
        alert_opt = AlertOption.new
        alert_opt.roles_user_id = roles_user_id
        alert_opt.alert_type_id = alert_type.id
        alert_opt.phone_active = opts.phone_active
        alert_opt.email_active = opts.email_active
        alert_opt.text_active = opts.text_active
        alert_opt.save
      end
      
      alert_opt[column.to_sym] = opts[column.to_sym]
      alert_opt.save
    end
    # AlertType.find(:all, :conditions => "alert_group_id = #{alert_group_id}").each do |alert_type|
    #   unless alert_opt = AlertOption.find(:first, :conditions => "roles_user_id = #{roles_user_id} and alert_type_id = #{alert_type.id}")
    #     alert_opt = AlertOption.new
    #     alert_opt.roles_user_id = roles_user_id
    #     alert_opt.alert_type_id = alert_type.id
    #     alert_opt.phone_active = opts.phone_active
    #     alert_opt.email_active = opts.email_active
    #     alert_opt.text_active = opts.text_active
    #     alert_opt.save
    #   end
    #   
    #   alert_opt[column.to_sym] = opts[column.to_sym]
    #   alert_opt.save
    # end
  end
  
  def toggle_phone
    toggle_critical('phone', params[:id]) unless User.find(params[:user_id]).profile.home_phone.empty?
    
    #render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def toggle_email
    toggle_critical('email', params[:id]) if User.find(params[:user_id]).email
    
    render :partial => "call_list/item", :locals => { :call_order => @call_order }
  end
  
  def toggle_text
    toggle_critical('text', params[:id]) unless User.find(params[:user_id]).profile.cell_phone.empty?
    
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
