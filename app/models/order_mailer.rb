class OrderMailer < ActionMailer::ARMailer
  # when charge on card fails
  def card_failure_alert(payment_gateway_response)
    recipients  "exceptions_critical@halomonitoring.com"
    from        "alert@halomonitoring.com"
    subject     "Credit Card transaction failed or declined"
    body        :response => payment_gateway_response
  end
  
  # when exception happens while creating log of payment gateway response
  def payment_gateway_response_exception(payment_gateway_response, message = "")
    recipients  "exceptions_critical@halomonitoring.com"
    from        "alert@halomonitoring.com"
    subject     "Exception while creating a credit card transaction log"
    body        :response => payment_gateway_response, :message => message
  end
end
