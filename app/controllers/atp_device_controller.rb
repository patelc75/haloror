#Important associations for this file
# devices ---> device_revisions <---> atp_items
#              device_revisions ----> device_model ---> device_type
#              device_revisions <---> work_orders
  class AtpDeviceController < ApplicationController
  
  #returns an XML doc of a single device (revision, model, type) along with its associated atp items
  #The device_revision is needed to get all model, type, and associated atp items. If it's not passed in, then it get be queried from the work_order_id
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
                {:device_revision => {:include => {:atp_items => {}, :device_model => {:include => {:device_type => {}}}}}})}
      end
    else
      respond_to do |format|
        format.xml {head :internal_server_error}
      end
    end
  end
  
  private
  
  #returns the device_revision_id based on the serial number's first two chars (eg. H1) and the work_order_id
  #by searching the many-to-many device_revisons_work_orders table. If the device_revision_id is passed in, return it back without doing anything
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