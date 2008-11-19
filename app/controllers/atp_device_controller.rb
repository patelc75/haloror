class AtpDeviceController < ApplicationController
  def index
    serial_number = params[:serial_number]
    if !serial_number.blank?
      device = Device.find_by_serial_number(serial_number, :include => [{:device_revision => {:device_model => :device_type}}])
      respond_to do |format|
        format.xml {render :xml => device.to_xml(:dasherize => false, :skip_types => true, :include => {:device_revision => {:include => {:device_model => {:include => :device_type}}}})}
      end
    else
      respond_to do |format|
        format.xml {head :internal_server_error}
      end
    end
  end
end