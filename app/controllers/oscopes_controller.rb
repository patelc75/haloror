require 'fastercsv'
class OscopesController < ApplicationController
  
  def csv
    start_msg_id = params[:id]
    o_start_msg = OscopeStartMsg.find(start_msg_id, :include => :oscope_msgs)
    o_msgs = o_start_msg.oscope_msgs
    csv_header = <<-EOF
      SOURCE MOTEID:  #{o_start_msg.source_mote_id}
      UID:  #{o_start_msg.user_id}
      CAPTURE REASON:  #{o_start_msg.capture_reason}
      TIMESTAMP:  #{o_start_msg.timestamp}
      ===============================================================================
      \n
    EOF

    csv_string = FasterCSV.generate do |csv|
      grid = generate_grid(o_msgs)
      grid.each do |row|
        csv << row
      end
    end
    csv_string = csv_header + csv_string
    send_data csv_string, :type => "text/plain", 
     :filename=>"oscope.csv", 
     :disposition => 'attachment'

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
      
    sequences.uniq.sort!
    channel_nums.uniq.sort!
    header = ['SN']    
    channel_nums.each do |channel_num|
      header << "CH#{channel_num}"
    end    
    
    grid << header
    
    sequences.each do |seq|
      row = [seq]
      channel_nums.each do |channel_num|
        row << data[seq][channel_num]
      end     
      grid << row 
    end 
    return grid
  end
end