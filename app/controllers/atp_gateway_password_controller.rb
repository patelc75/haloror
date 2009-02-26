class AtpGatewayPasswordController < ApplicationController
  def index
    serial_number = params[:gateway_access][:serial_number]  if params[:gateway_access]
    password = GatewayPassword.generate_password(serial_number)
    xml = get_gateway_access_xml(serial_number, password)
    respond_to do |format|
      format.xml {render(:xml => xml)}
    end
  end
  
  def retrieve
    serial_number = params[:gateway_access][:serial_number]  if params[:gateway_access]
    password = GatewayPassword.retrieve_password(serial_number)
    xml = get_gateway_access_xml(serial_number, password)
    respond_to do |format|
      format.xml {render(:xml => xml)}
    end
  end
  private
  
  def get_gateway_access_xml(serial_number, password)
    xml = "<gateway_access><serial_number>#{serial_number}</serial_number>"
    xml = xml + "<password>#{password}</password>" if password
    xml = xml + "</gateway_access>"
    return xml
  end
end