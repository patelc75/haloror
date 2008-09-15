class OscopeMsgsController < RestfulAuthController
  def create
    begin
      o_msgs = params[:oscope_msgs]
      msgs = o_msgs[:oscope_msg]
      if msgs.class != Array
        msgs = [msgs]
      end
      o_start_msg = nil
      timestamp = nil
      user_id = nil
      if msgs.size > 0
        timestamp = msgs[0][:timestamp].to_time if msgs[0][:timestamp]
        user_id = msgs[0][:user_id] if msgs[0][:user_id]
        if user_id && timestamp
          o_start_msg = OscopeStartMsg.find_by_timestamp_and_user_id("'#{timestamp.to_s(:db)}'", user_id)
        end
      end
      if o_start_msg
        msgs.each do |msg|
          timestamp = msg[:timestamp].to_time if msg[:timestamp]
          channel_num = msg[:channel_num].to_i if msg[:channel_num]
          user_id = msg[:user_id].to_i if msg[:user_id]
          o_msg = OscopeMsg.new
          o_msg.timestamp = timestamp
          o_msg.channel_num = channel_num
          o_msg.user_id = user_id
          o_msg.oscope_start_msg = o_start_msg
          o_msg.save!
          points = msg[:point]
          if points.class == Array
            points.each do |point|
              save_point(o_msg, point)
            end
          else
            save_point(o_msg, points)
          end
        end
      else
        raise "No oscope start msg found."
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
  
  private
  
  def save_point(o_msg, point)
    p = Point.new(point)
    p.oscope_msg = o_msg
    p.save!
  end
end
