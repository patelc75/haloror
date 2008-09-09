class OscopeMsgsController < RestfulAuthController
  def create
    begin
    msg = params[:oscope_msg]
    timestamp = msg[:timestamp].to_time if msg[:timestamp]
    channel_num = msg[:channel_num].to_i if msg[:channel_num]
    o_msg = OscopeMsg.find_by_timestamp("'#{timestamp.to_s(:db)}'")
    unless o_msg
      o_msg = OscopeMsg.new
      o_msg.timestamp = timestamp
      o_msg.channel_num = channel_num
      o_msg.save!
    end
    points = msg[:point]
    if points.class == Array
      points.each do |point|
        save_point(o_msg, point)
      end
    else
      save_point(o_msg, points)
    end
    respond_to do |format|
        format.xml { head :ok } 
    end
    rescue RuntimeError => e
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
