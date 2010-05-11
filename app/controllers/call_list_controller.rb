class CallListController < ApplicationController

  #before_filter :authenticate_admin_operator?, :except => 'show'
  before_filter :authenticate_admin_halouser_caregiver_operator_sales_installer?, :only => 'show'
  
  def recently_activated
    
  end
  
  def show
    number_ext
    session[:redirect_url] = request.env['REQUEST_URI']
    if(!params[:id].blank?)
      #
      # WARNING: What happens if profile does not exist for a user found here?
      #   The view file updated to conditionally block the features when profile is missing
      #   A more appropriate business logic is required here
      #
      @user = User.find(params[:id])
      get_caregivers(@user)
      groups = @user.group_memberships
      unless((@user.id == current_user.id) || current_user.patients.include?(@user) || current_user.is_super_admin? || current_user.is_admin_of_any?(groups) || current_user.is_operator_of_any?(groups) || current_user.is_sales_of_any?(groups) || current_user.is_installer_of_any?(groups))    
        redirect_to :action => 'unauthorized', :controller => 'security'
      end
    else
      @user = current_user
      get_caregivers(@user)
    end
  end
  
  def sort
    user = User.find(params[:user_id])
    get_caregivers(user)
    @caregivers.each do |position, caregiver|
      roles_user = user.roles_user_by_caregiver(caregiver)		
      opts = roles_user.roles_users_option
      if new_pos = params['call_list'].index(roles_user.user_id.to_s)
        opts.position = new_pos + 1
        opts.save
      end
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
    user = User.find(params[:user_id])
    toggle_critical('phone', params[:id]) unless user.profile.home_phone.blank? && user.profile.cell_phone.blank?
    render :text => '', :layout => false
  end
  
  def toggle_email
    toggle_critical('email', params[:id]) if User.find(params[:user_id]).email
    render :text => '', :layout => false
  end
  
  def toggle_text
  	@user = User.find(params[:user_id])
  	unless @user.profile.cell_phone.blank? || @user.profile.carrier_id == nil || @user.profile.carrier_id == ""
      toggle_critical('text', params[:id])
    end
    render :text => '', :layout => false
  end
  
  def activate
    RolesUsersOption.update(params[:id], {:active => 1})
    render :text => '', :layout => false
  end
  
  def deactivate
    RolesUsersOption.update(params[:id], {:active => 0})
    render :text => '', :layout => false
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
