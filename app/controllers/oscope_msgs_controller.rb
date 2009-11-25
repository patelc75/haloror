class OscopeMsgsController < RestfulAuthController
  def create
    begin
      OscopeMsg.process_oscope_msg(params_array)
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
  
  private
  
  def save_point(o_msg, point)
    p = Point.new(point)
    p.oscope_msg = o_msg
    p.save!
  end
end
