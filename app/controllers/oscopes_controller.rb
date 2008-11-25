require 'fastercsv'
class OscopesController < ApplicationController
  before_filter :authenticate_admin?
  def index
    @capture_reasons = OscopeStartMsg.capture_reasons
    RAILS_DEFAULT_LOGGER.warn("CAPTURE_REASONS=>#{@capture_reasons}")
  end
  def csv
   begin
    start_msg_id = params[:id]
    user_id = params[:user_id]
    reason = params[:reason]
    begin_timestamp = params[:begin_timestamp]
    end_timestamp =  params[:end_timestamp]
    o_start_msgs = []
    if(!start_msg_id.blank?)
      o_start_msgs = [OscopeStartMsg.find(start_msg_id, :include => :oscope_msgs)]
    else
      conds = ''
      if(!user_id.blank?)
        conds << " user_id = #{user_id} "
      end
      if(!reason.blank?)
        if(!conds.blank?)
          conds << " AND "
        end
        conds << " capture_reason = '#{reason}'"
      end
      if(!begin_timestamp.blank?)
        if(!conds.blank?)
          conds << " AND "
        end
        conds << " timestamp >= '#{timestamp.to_s(:db)}' "
      end
      if(!end_timestamp.blank?)
        if(!conds.blank?)
          conds << " AND "
        end
        conds << " timestamp <= '#{timestamp.to_s(:db)}' "
      end
      o_start_msgs = OscopeStartMsg.find(:all, :conditions => conds, :include => :oscope_msgs)
    end
    csv_string_all = ''
    o_start_msgs.each do |o_start_msg|
      o_msgs = o_start_msg.oscope_msgs
      csv_header = <<-EOF
        \n
        SOURCE MOTEID:  #{o_start_msg.source_mote_id}
        UID:  #{o_start_msg.user_id}
        CAPTURE REASON:  #{o_start_msg.capture_reason}
        TIMESTAMP:  #{o_start_msg.timestamp}
        ===============================================================================
        \n
      EOF
      
      grid = generate_grid(o_msgs)
      csv_string = FasterCSV.generate do |csv|
        grid.each do |row|
          csv << row
        end
      end
      csv_string_all = csv_header + csv_string
    end
    send_data csv_string_all, :type => "text/plain", 
     :filename=>"oscope.csv", 
     :disposition => 'attachment'
   rescue Exception => e
     flash[:warning] = 'Error retrieving information.'
     render :action => 'index'
   end
  end
  
  private
  
  def generate_grid(o_msgs)
    grid = []
    channel_nums = []
    sequences = []
    data = {}
    o_msgs.each do |msg|
      channel_num = msg.channel_num
      channel_nums << channel_num
      msg.points.each do |point|
        unless data[point.seq]
          data[point.seq] = {}
        end
        data[point.seq][channel_num]= point.data
        sequences << point.seq
      end      
    end
      
    sequences = sequences.uniq
    sequences.sort!
    channel_nums = channel_nums.uniq
    channel_nums.sort!
    header = ['SN']    
    channel_nums.each do |channel_num|
      header << "CH#{channel_num}"
    end    
    
    grid << header
    
    sequences.each do |seq|
      row = [seq]
      channel_nums.each do |channel_num|
        if data[seq][channel_num]
          row << data[seq][channel_num]
        else
          row << 0 
        end
      end     
      grid << row 
    end 
    return grid
  end
end