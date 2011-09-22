class OscopeMsgsController < RestfulAuthController
  # make_resourceful do 
  #   actions :all
  #   
  #   response_for :create do |format|
  #     format.xml { head :ok }
  #     format.html { render :nothing => true }
  #   end
  #   
  #   response_for :create_fails do |format|
  #     format.xml { head :internal_server_error }
  #     format.html { render :nothing => true }
  #   end
  #   
  #   after :create do
  #     respond_to do |format|
  #       format.xml { head :ok }
  #     end
  #   end
  #   
  #   after :create_fails do
  #     RAILS_DEFAULT_LOGGER.warn("ERROR in OscopeMsgController:  #{e}")
  #     respond_to do |format|
  #       format.xml { head :internal_server_error }
  #     end
  #   end
  # end
  
  def create
    begin
      if !params[:oscope_msgs].nil? 
        o_msgs_attributes = params[:oscope_msgs]   
        msgs_attributes = o_msgs_attributes[:oscope_msg] #o_msgs[:oscope_msg] is automatically stored as an array of <oscope_msg> nodes by Rails       
        OscopeStartMsg.create!( o_msgs_attributes[:oscope_start_msg]) if !o_msgs_attributes[:oscope_start_msg].blank? 
        OscopeStopMsg.create!( o_msgs_attributes[:oscope_stop_msg])   if !o_msgs_attributes[:oscope_stop_msg].blank? 
      elsif !params[:oscope_msg].nil?   
        msgs_attributes = params[:oscope_msg] #params is a hash but everything underneath is arrays. 
      end
      
      # make it an array if not already
      msgs_attributes = [msgs_attributes] unless msgs_attributes.class == Array

      # this will fire an exception if the record in not valid
      # exception will fall to rescue block and send :internal_server_error
      msgs_attributes.each {|msg_attributes| OscopeMsg.create!(msg_attributes) }
      # msgs.each {|msg| OscopeMsg.process_xml_hash(msg)}

      # respond_to block required. without this block the rendering will default to format.html
      # https://redmine.corp.halomonitor.com/issues/2746
      respond_to do |format|
        format.xml { head :ok } # if execution reaches here, everything was normal. send :ok status
      end
    
    rescue Exception => e
      # any exception during save! will trigger this, and send :internal_server_error status
      RAILS_DEFAULT_LOGGER.warn("ERROR in OscopeMsgController:  #{e}")
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
    end
  end
  
end
