class InstallationInProgressController < RestfulAuthController
  
  def create
    user_id = params[:installation][:user_id]
    range_timestamp = 1.day.ago

    self_test_session = SelfTestSession.find(:first, 
                                            :conditions => "user_id = #{user_id} AND created_at > '#{range_timestamp}'", #AND completed_on IS NULL",  
                                            :order => 'created_at desc')

	  xml = nil
    if self_test_session
      	if self_test_session.completed_on == nil
			xml = installation_in_progress_xml(true)
		else
			xml = installation_in_progress_xml(false)
		end	
    else
      xml = installation_in_progress_xml(false)
    end
    
    respond_to do |format|
      format.xml {render :xml => xml}
    end
  end
  
  def installation_in_progress_xml(in_progress)
    xml = "<installation><in_progress>#{in_progress}</in_progress></installation>"
    return xml
  end
  
end