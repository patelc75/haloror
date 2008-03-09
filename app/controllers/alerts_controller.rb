class AlertsController < ApplicationController
  def index
    @alerts = User.find(params[:id]).roles_users_option.alerts
  end
  
  def toggle_phone
    alert = Alert.find(params[:id])

    if !alert.phone_active
      alert.phone_active = true
    else
      alert.phone_active = false
    end
    
    alert.save
    
    render :nothing => true
  end
  
  def toggle_email
    alert = Alert.find(params[:id])

    if !alert.email_active
      alert.email_active = true
    else
      alert.email_active = false
    end
    
    alert.save
    
    render :nothing => true
  end
  
  def toggle_text
    alert = Alert.find(params[:id])

    if !alert.text_active
      alert.text_active = true
    else
      alert.text_active = false
    end
    
    alert.save
    
    render :nothing => true
  end
end
