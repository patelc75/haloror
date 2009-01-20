class AtpDeviceController < ApplicationController
  def index
    serial_number = params[:serial_number]
    work_order_id = params[:work_order_id]
    device_revision_id = params[:device_revision_id]
    device = nil
    if !serial_number.blank?
      device = Device.find_by_serial_number(serial_number, 
                                              :include => [:work_order, {:device_revision => {:device_model => :device_type}}])
      if(!work_order_id.blank?)
        device.work_order_id = work_order_id
        device_revision_id = get_device_revision_id(device_revision_id)
        device.device_revision_id = device_revision_id
        device.save!
      end
      respond_to do |format|
        format.xml {render :xml => device.to_xml(:dasherize => false, :skip_types => true, 
          :include => {:work_order => {},
                       :device_revision => {:include => 
                        {:device_model => {:include => 
                          {:device_type => {:include => 
                            :atp_items}}}}}})}
      end
    else
      respond_to do |format|
        format.xml {head :internal_server_error}
      end
    end
  end
end