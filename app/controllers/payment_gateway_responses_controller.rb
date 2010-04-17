class PaymentGatewayResponsesController < ApplicationController

  def index
    @payment_gateway_responses = PaymentGatewayResponse.paginate :page => params[:page], :per_page => 20,:order => 'created_at desc'	
  end
  
  def details
  	@payment_gateway_responses = PaymentGatewayResponse.find(params[:id])
  end

end
