class AtpKitsController < ApplicationController
  def index
    xml = ""
    bad_serials = []
    kit_hash = params[:kit]
    sns = kit_hash[:serial_numbers]
    serial_numbers = sns[:serial_number]
    if serial_numbers && serial_numbers.class != Array
      serial_numbers = [serial_numbers]
    end
    RAILS_DEFAULT_LOGGER.warn(serial_numbers.inspect)
    if serial_numbers.size > 0
    begin
      Kit.transaction do 
        @kit = Kit.create()
        serial_numbers.each do |sn|
          device = Device.find_by_serial_number(sn)
          if device
            @kit.devices << device
            RAILS_DEFAULT_LOGGER.warn @kit.devices
          else
            bad_serials << sn
          end
        end
        if bad_serials.size > 0
          raise "Serial Number(s) not found."
        else
          @kit.save!
        end
      end
    rescue RuntimeError => e
      
        RAILS_DEFAULT_LOGGER.warn("ERROR in AtpKitsController:  #{e}")
    end
      if bad_serials.size > 0
        xml = "<kit><serial_numbers>"
        bad_serials.each do |sn|
          xml += "<serial_number>#{sn}</serial_number>"
        end
        xml += "</serial_numbers></kit>"
      else
        xml = "<kit><id>#{@kit.id}</id></kit>"
      end
      respond_to do |format|
        format.xml {render :xml => xml}
      end
    else
      render :text => ''
    end
  end
  
end