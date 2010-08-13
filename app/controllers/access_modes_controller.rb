class AccessModesController < RestfulAuthController  
  def create
    @access_mode = AccessMode.new(params[:access_mode])

    if @access_mode.save
      check
    else
      respond_to do |format|         
        format.html { render :action => "new" }
        format.xml  { render :xml => @access_mode.errors.to_xml }
      end
    end
  end

  def authenticated?
    if action_name == 'create' or action_name == 'check' 
      return authorize
    else
      return false
    end
  end
  
  def check
    # WARNING: DRYed. needs testing
    #
    # device_id = params[:access_mode][:device_id] #device_id not being used
    mode = params[:access_mode][:mode]
    #
    # TODO: should this be?     Group.default.system_timeouts.find_by_mode( mode)
    poll_rate = timeout.gateway_offline_timeout_sec if ( timeout = SystemTimeout.find_by_mode(mode) )
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