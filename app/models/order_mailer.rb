class OrderMailer < ActionMailer::ARMailer
  # when charge on card fails
  def card_failure_alert(payment_gateway_response)
    recipients  "payment_gateway@halomonitoring.com"
    from        "no-reply@halomonitoring.com"
    subject     "[" + ServerInstance.current_host_short_string + "]" + "Credit Card transaction failed or declined"          
    body        :response => payment_gateway_response
  end
  
  # when exception happens while creating log of payment gateway response
  def payment_gateway_response_exception(payment_gateway_response, message = "")
    recipients  "payment_gateway@halomonitoring.com"
    from        "no-reply@halomonitoring.com"
    subject     "[" + ServerInstance.current_host_short_string + "]" + "Exception while creating a credit card transaction log"
    body        :response => payment_gateway_response, :message => message
  end
  
  # 
  #  Mon Dec 27 23:59:16 IST 2010, ramonrails
  #   * email when any error happens in encryption or decryption of sensitive data
  def encryption_decryption_exception( _order, _message = "")
    recipients  "payment_gateway@halomonitoring.com"
    from        "no-reply@halomonitoring.com"
    subject     "[" + ServerInstance.current_host_short_string + "] Order:#{_order.id} " + "Encrypting or Decrypting sensitive data has error"
    body        :order => _order, :message => _message
  end
end
