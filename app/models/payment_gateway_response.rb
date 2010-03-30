class PaymentGatewayResponse < ActiveRecord::Base
  belongs_to :order
  serialize :params # hash to string helps to save in database
  after_save :send_alert_email_if_failure
  
  # parse and store response details appropriately
  #
  def response=(response)
    if response.is_a?(Hash)
      self.success       = response[:success]
      self.authorization = response[:authorization]
      self.message       = response[:message]
      self.params        = response[:params]
    else
      begin
        self.success       = response.success?
        self.authorization = response.authorization
        self.message       = response.message
        self.params        = response.params
      rescue ActiveMerchant::ActiveMerchantError => e
        self.success       = false
        self.authorization = nil
        self.message       = e.message
        self.params        = {}
        OrderMailer.deliver_payment_gateway_rsponse_exception(self, e.message) unless self.success
      end
    end
  end
  
  # send alert email to admin when card transaction fails
  #
  def send_alert_email_if_failure
    OrderMailer.deliver_card_failure_alert(self) unless self.success
  end
end
