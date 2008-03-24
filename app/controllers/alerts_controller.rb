class AlertsController < ApplicationController
  def index
    @alerts = RolesUser.find(params[:id]).alert_options
  end
  
  def toggle_phone
    alert = AlertOption.find(params[:id])

    if !alert.phone_active
      alert.phone_active = true
    else
      alert.phone_active = false
    end
    
    alert.save
    
    render :nothing => true
  end
  
  def toggle_email
    alert = AlertOption.find(params[:id])

    if !alert.email_active
      alert.email_active = true
    else
      alert.email_active = false
    end
    
    alert.save
    
    render :nothing => true
  end
  
  def toggle_text
    alert = AlertOption.find(params[:id])

    if !alert.text_active
      alert.text_active = true
    else
      alert.text_active = false
    end
    
    alert.save
    
    render :nothing => true
  end
end
