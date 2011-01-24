class CallListController < ApplicationController

  #before_filter :authenticate_admin_operator?, :except => 'show'
  before_filter :authenticate_admin_halouser_caregiver_operator_sales_installer?, :only => 'show'
  
  def recently_activated
    
  end
  
  def show
    number_ext
    session[:redirect_url] = request.env['REQUEST_URI']
    if(!params[:id].blank?)
      # old logic back
      @user = (User.find(params[:id]) || current_user) # show caregivers of current_user when user not found
      #
      # required business logic is (for UIQ, user-in-question = user for which caregivrs are listed here)
      # user = caregiver, user != halouser, show caregivers of halouser
      # user = caregiver, user = halouser, show caregivers of self (caregiver)
      # * any user can have any number of rols
      # * as long as UIQ has caregivers, just show them
      # * if UIQ does not have any caregivers, then fetch caregivers of its first halouser
      #
      @user = @user.is_caregiver_for_what.first if @user.caregivers.blank? && @user.is_caregiver? && !@user.is_caregiver_for_what.blank?
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
      if ( opts = roles_user.roles_users_option )
      if new_pos = params['call_list'].index(roles_user.user_id.to_s)
        opts.position = new_pos + 1
        opts.save
      end
      end
    end
    render :text => '', :layout => false
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
    # AlertType.find(:all, :conditions => "alert_group_id = #{alert_group_id}").each do |alert_type|     
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
    # 
    #  Wed Dec 22 00:03:32 IST 2010, ramonrails
    #   * more robust conditions
    #   * added a flash message if this was not updated
    # if @user.profile.cell_phone.blank? || @user.profile.carrier_id == nil || @user.profile.carrier_id == ""
    if @user.profile.blank? || @user.profile.cell_phone.blank? || @user.profile.carrier.blank?
      render :update do |page|
        flash[:notice] = "Cannot update phone toggle: User profile, cell phone or carrier is missing."
        page.reload_flash # load flash explicitly. this is AJAX call
      end
    else
      toggle_critical('text', params[:id])
      render :text => '', :layout => false
    end
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
