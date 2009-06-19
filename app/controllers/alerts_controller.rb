class AlertsController < ApplicationController
  before_filter :authenticate_admin_halouser_caregiver_sales?
  def index
    @alert_types = []
    #AlertGroup.find(:all, :conditions => "group_type != 'critical'").each do |group|
    #AlertType.find(:all, :conditions => "alert_group_id = #{group.id}").each do |type|
    AlertType.find(:all).each do |type|    
      @alert_types << type        
    end
    roles_user = RolesUser.find(params[:id])
    user = User.find(roles_user.user_id)
    if roles_user.user_id == current_user.id || current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships) || current_user.caregivers.include?(user)
      @roles_user = roles_user
    else
      redirect_to :action => 'unauthorized', :controller => 'security'
    end
  end

  
  def toggle(what) 
    
    roles_user = RolesUser.find(params[:roles_user_id])    
    user = User.find(roles_user.user_id)
    if roles_user.user_id == current_user.id || current_user.is_super_admin? || current_user.is_admin_of_any?(user.group_memberships) || current_user.caregivers.include?(user)
      @roles_user = roles_user
       
    #if alert_opt = AlertOption.find(:first,:conditions => "roles_user_id = #{params[:id]} and alert_type_id = #{alert.id}")

   
      unless alert_opt = AlertOption.find(:first, :conditions => "roles_user_id = #{@roles_user.id} and alert_type_id = #{params[:id]}")
        alert_type = AlertType.find(params[:id])
      
        alert_opt = AlertOption.new
        alert_opt.roles_user_id = @roles_user.id
        alert_opt.alert_type_id = alert_type.id
        alert_opt.phone_active = alert_type.phone_active
        alert_opt.email_active = alert_type.email_active
        alert_opt.text_active = alert_type.text_active
        alert_opt.save
      end
    
      column = "#{what}_active"
    
      if !alert_opt[column.to_sym]
        state = 1
      else
        state = 0
      end
    
      alert_opt[column.to_sym] = state
      alert_opt.save!
    
      render :nothing => true
    else
      redirect_to :action => 'unauthorized', :controller => 'security'
    end
  end
  
  def toggle_phone
    toggle('phone')
    
  end
  
  def toggle_email
    toggle('email')
  end
  
  def toggle_text
    toggle('text')
  end
end
