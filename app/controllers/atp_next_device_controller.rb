class AtpNextDeviceController < ApplicationController
  def index
    work_order_id = params[:work_order_id]
    revision_id = params[:device_revision_id]
    if !work_order_id.blank? && !revision_id.blank?
      xml = get_xml(work_order_id, revision_id)
      respond_to do |format|
        format.xml do
          if xml
            render :xml => xml
          else
            head :ok
          end          
        end
      end
    else
      respond_to do |format|
        format.xml {head :internal_server_error}
      end
    end
  end
  
  private
  
  def get_xml(work_order_id, revision_id)
    
    return nil if work_order_id.blank? || revision_id.blank?
    xml = nil
    dt_wo = DeviceRevisionsWorkOrder.find(:first, :conditions => "work_order_id = #{work_order_id} AND device_revision_id = #{revision_id}")
    if dt_wo && (dt_wo.total_serial_nums < dt_wo.num)
      serial_number = get_next_serial_number(dt_wo)
      mac_address = get_next_mac_address(serial_number, dt_wo)
      device = Device.new(:serial_number => serial_number, :mac_address => mac_address, :device_revision_id => revision_id, :work_order_id => work_order_id)
      device.save!
      xml = device.to_xml(:dasherize => false, :skip_types => true, :include => {:device_revision => {:include => {:device_model => {:include => {:device_type => {:include => :atp_items}}}}}})
    end
    return xml
  end
  
  # returns next serial number
  # serial number has the form 
  # starting_serial_num takes first 5 spaces
  # the last 5 spaces range between 0 - 65,525
  # example H100012345
  def get_next_serial_number(dt_wo)
    dt_wo.total_serial_nums += 1
    raise "invalid serial number" if dt_wo.total_serial_nums > 65525
    end_num = dt_wo.total_serial_nums.to_s
    serial_number = dt_wo.starting_serial_num
    serial_number = serial_number.ljust(10, "0")
    serial_number[serial_number.size - end_num.size, serial_number.size]= end_num
    dt_wo.current_serial_num = serial_number
    dt_wo.save!
    return serial_number
  end
  
  # returns the mac address generated from the serial number
  # mac address has the form
  # starting mac_address takes first 6 XX:XX:XX 
  # followed by 00
  # followed by hex of last part of serial number
  # example XX:XX:XX:00:A0:B0
  def get_next_mac_address(serial_number, dt_wo)
    dt_wo.total_mac_addresses += 1
    serial_number = serial_number[5,5].to_i
    
    serial_number = serial_number.to_s(16)
    serial_number = serial_number.rjust(4, '0')
    mac_address = dt_wo.starting_mac_address + '00' + ':' + serial_number[0,2] + ':' + serial_number[2,2]
    dt_wo.current_mac_address = mac_address
    dt_wo.save!
    return mac_address
  end
end