class AccessModesController < RestfulAuthController  
  def authenticated?
    if action_name == 'create' or action_name == 'check' 
      return authorize
    else
      return false
    end
  end
  
  def check
    device_id = params[:access_mode][:device_id] #device_id not being used
    mode = params[:access_mode][:mode] 

	timeout = SystemTimeout.find_by_mode(mode)
	
	if timeout
	  poll_rate = timeout.gateway_offline_timeout_sec	
	end
	
	xml = check_poll_rate_xml(mode, poll_rate)
    
    respond_to do |format|
      format.xml {render :xml => xml}
    end
  end
  
  def check_poll_rate_xml(mode, poll_rate)
    xml = "<access_mode><mode>#{mode}</mode><poll_rate>#{poll_rate}</poll_rate></access_mode>"
    return xml
  end
end