class AtpDeviceController < ApplicationController
  def index
    serial_number = params[:serial_number]
    work_order_id = params[:work_order_id]
    device_revision_id = params[:device_revision_id]
    device = nil
    if !serial_number.blank?
      device = Device.find_by_serial_number(serial_number, 
                                              :include => [:work_order, {:device_revision => [:atp_items, {:device_model => :device_type}]}])
      if(!work_order_id.blank?)
        device.work_order_id = work_order_id
        device_revision_id = get_device_revision_id(device_revision_id, work_order_id, serial_number)
        device.device_revision_id = device_revision_id
        device.save!
      end
      respond_to do |format|
        format.xml {render :xml => device.to_xml(:dasherize => false, :skip_types => true, 
          :include => 
              {:device_revision => {:include => {:atp_items => {}, :device_model => {:device_type => {}}}}})}
      end
    else
      respond_to do |format|
        format.xml {head :internal_server_error}
      end
    end
  end
  
  private
  def get_device_revision_id(id, work_order_id, serial_number)
    if !id.blank?
      return id
    else
      t = ''
      sn = serial_number[0,2]
      t = DEVICE_TYPES[sn.to_sym]
      
      drwo = DeviceRevisionsWorkOrder.find(:first, 
                                            :include => {:device_revision => {:device_model => :device_type}},
                                            :conditions => "work_order_id = #{work_order_id} AND device_revisions_work_orders.device_revision_id IN (Select device_revisions.id from device_revisions inner join (device_models inner join device_types on device_models.device_type_id = device_types.id) on device_revisions.device_model_id = device_models.id Where device_types.device_type = '#{t}')",
                                            :order => "device_revisions_work_orders.created_at desc")
      return drwo.device_revision_id      
    end
  end
end