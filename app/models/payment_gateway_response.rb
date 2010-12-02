class PaymentGatewayResponse < ActiveRecord::Base
  include ApplicationHelper

  belongs_to :order
  serialize :params # hash to string helps to save in database
  
  # Usage:
  #   PaymentGatewayResponse.successful
  #   PaymentGatewayResponse.successful.subscription
  #   PaymentGatewayResponse.purchase.failed
  named_scope :successful,    :conditions => { :success => true  }
  named_scope :failed,        :conditions => { :success => false }
  named_scope :subscription,  :conditions => { :action  => 'recurring' }
  named_scope :pro_rata,      :conditions => { :action  => 'pro-rata' }
  # 
  #  Thu Nov 25 00:18:21 IST 2010, ramonrails
  #   * "purchase" was changed to "deposit + shipping"
  #   * inculude both in the search
  named_scope :purchase,      :conditions => { :action  => ['deposit + shipping', 'purchase']  }

  after_save :send_alert_email_if_failure

  # parse and store response details appropriately
  #
  def response=(response)
    if response.is_a?(Hash)
      self.success       = response[:success]
      self.authorization = response[:authorization]
      self.message       = response[:message]
      self.params        = response[:params]
      self.request_data  = response[:request_data]
      self.request_headers = response[:request_headers]
    else
      begin
        # 
        #  Wed Dec  1 02:47:48 IST 2010, ramonrails
        #   * https://redmine.corp.halomonitor.com/issues/3805
        #   * invalid amount is considered a success, not failure
        self.success       = ( response.success? || response.message.include?( 'valid amount is required'))
        self.authorization = response.authorization
        self.message       = response.message
        self.params        = response.params
        self.request_data  = response.request_data
        self.request_headers = response.request_headers
      rescue ActiveMerchant::ActiveMerchantError => e
        self.success       = false
        self.authorization = nil
        self.message       = e.message
        self.params        = {}
        self.request_data  = response.request_data
        self.request_headers = response.request_headers
        OrderMailer.deliver_payment_gateway_rsponse_exception(self, e.message) unless self.success
      end
    end
  end

  # send alert email to admin when card transaction fails
  #
  def send_alert_email_if_failure
    OrderMailer.deliver_card_failure_alert(self) unless self.success
  end

  def field_to_html(field)
    if self.respond_to?(field)
      case field
      when "message", "request_headers"
        self.send(field.to_sym)
      when "params"
        hash_to_html(params) # params.collect {|k,v| "<p>#{k} => #{v}</p>" }.flatten.to_s
      when "request_data"
        if request_data.include?("<?xml")
          hash_to_html(Hash.from_xml(request_data))
        else
          "<ul><li>" + request_data.gsub("="," => ").split("&").join("</li><li>") + "</li></ul>"
        end
      end
    else
      ""
    end
  end
end
