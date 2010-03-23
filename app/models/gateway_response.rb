class GatewayResponse < ActiveRecord::Base
  belongs_to :order
  serialize :params # hash to string helps to save in database
  
  # parse and store response details appropriately
  #
  def response=(response)
    self.success       = response.success?
    self.authorization = response.authorization
    self.message       = response.message
    self.params        = response.params
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success       = false
    self.authorization = nil
    self.message       = e.message
    self.params        = {}
  end
end
