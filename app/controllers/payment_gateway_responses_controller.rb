class PaymentGatewayResponsesController < ApplicationController

  def index
    if params[:order_id] 
      conds = ["order_id = #{params[:order_id]}"]      
      @payment_gateway_responses = PaymentGatewayResponse.paginate :page => params[:page], :per_page => 20, :conditions => conds.join(' and '), :order => 'created_at desc'	      
    else
      @payment_gateway_responses = PaymentGatewayResponse.paginate :page => params[:page], :per_page => 20, :order => 'created_at desc'	
    end
  end
  
  def details
  	@payment_gateway_response = PaymentGatewayResponse.find(params[:id].to_i)
  	@column = params[:column]
  end

end
