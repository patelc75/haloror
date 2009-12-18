class OscopeMsgsController < RestfulAuthController
  def create
    begin
      o_msgs = params[:oscope_msgs] #params is a hash but everything underneath is arrays. 
      msgs = o_msgs[:oscope_msg] #o_msgs[:oscope_msg] is automatically stored as an array of <oscope_msg> nodes by Rails 
      
      if msgs.class != Array 
        msgs = [msgs]
      end
      
      msgs.each do |msg|
        OscopeMsg.process_oscope_msg(msg)
      end
      
      respond_to do |format|
        format.xml { head :ok } 
      end
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in OscopeMsgController:  #{e}")
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
    end
  end
end
