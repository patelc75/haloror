class AtpGatewayPasswordController < ApplicationController
  def index
    serial_number = params[:gateway_access][:serial_number]  if params[:gateway_access]
    password = GatewayPassword.generate_password(serial_number)
    xml = "<gateway_access><serial_number>#{serial_number}</serial_number>"
    xml = xml + "<password>#{password}</password>" if password
    xml = xml + "</gateway_access>"
    respond_to do |format|
      format.xml {render(:xml => xml)}
    end
  end
end