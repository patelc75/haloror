class PaymentGatewayResponsesController < ApplicationController

  def index
    @payment_gateway_responses = PaymentGatewayResponse.paginate :page => params[:page], :per_page => 20, :order => 'created_at desc'	
  end
  
  def details
  	@payment_gateway_response = PaymentGatewayResponse.find(params[:id].to_i)
  	@column = params[:column]
  end

end
