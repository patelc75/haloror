class OscopeMsgsController < RestfulAuthController
  def create
    begin                               
      if !params[:oscope_msgs].nil? 
       o_msgs = params[:oscope_msgs]   
       msgs = o_msgs[:oscope_msg] #o_msgs[:oscope_msg] is automatically stored as an array of <oscope_msg> nodes by Rails       
      elsif !params[:oscope_msg].nil?   
       msgs = params[:oscope_msg] #params is a hash but everything underneath is arrays. 
      end
      
      msgs = [msgs] if msgs.class != Array
      msgs.each {|msg| OscopeMsg.create!(msg)} # WARNING: tested manually
      # msgs.each {|msg| OscopeMsg.process_xml_hash(msg)}
      
      # TODO: optimize this after covering with test
      # {:create_fails => :internal_server_error, :create => :ok}.each do |key, value|
      #   response_for key do |format|
      #     format.xml { head value }
      #   end
      # end
      
      response_for :create_fails do |format|
        format.xml { head :internal_server_error }
      end
      
      response_for :create do |format|
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
