class Order < ActiveRecord::Base
  belongs_to :group
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  has_many :order_items
  has_many :payment_gateway_responses
  has_one :user_intake
  attr_accessor :card_csc, :product, :bill_address_same
  
  # causing failure of order. need to force kit_serial for retailer in some other way
  # validates_presence_of :kit_serial, :if => :retailer?
  
  def after_initialize
    populate_billing_address # copy billing address if bill_address_same
  end
  
  def group_name
    group.blank? ? "" : group.name
  end

  def reseller?
    group.blank? ? false : (group.sales_type == "reseller")
  end
  
  def retailer?
    group.blank? ? false : (group.sales_type == "retailer")
  end
  
  def need_to_force_kit_serial?
    self.retailer? && self.kit_serial.blank?
  end
  
  # quick shortcut for the bill and ship address same
  def subscribed_for_self?
    ((bill_address_same == "1") || ship_and_bill_address_match)
  end
    
  # find out if the product catalog has the product from HASH
  def product_from_catalog
    @product_found_in_catalog ||= DeviceModel.find_complete_or_clip(product) # cache
  end
  
  # tariff card for the product found in catalog
  def product_cost
    @product_tariff ||= product_from_catalog.tariff(:coupon_code => coupon_code)    
  end
  
  # create order_item enteries for this order
  def create_order_items
    device_model = product_from_catalog
    # create order item for product
    order_items.create!(:device_model_id => device_model.id, :cost => product_cost.upfront_charge, :quantity => 1)
    # create a recurring order item
    order_items.create!(:cost => product_cost.monthly_recurring, :quantity => 1, \
      :recurring_monthly => true, :device_model_id => device_model.id)
  end
  
  # same_as_shipping checkbox can reply on this
  def ship_and_bill_address_match
    ship = []; bill = []
    ["first_name", "last_name", "address", "city", "state", "zip", "phone", "email"].each do |field|
      ship << eval("ship_#{field}")
      bill << eval("bill_#{field}")
    end
    ship.eql?( bill)
  end
  
  # based on the above definitions
  def total_value
    value = 0
    order_items.each do |order_item|
      tariff = order_item.device_model.tariff(:coupon_code => coupon_code) unless order_item.device_model.blank?
      value += (tariff.deposit + tariff.shipping + tariff.upfront_charge) unless tariff.blank?
    end
    value
  end
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end

  # reference from active_merchant code
  #
  # === Gateway Options
  # The options hash consists of the following options:
  #
  # * <tt>:order_id</tt> - The order number
  # * <tt>:ip</tt> - The IP address of the customer making the purchase
  # * <tt>:customer</tt> - The name, customer number, or other information that identifies the customer
  # * <tt>:invoice</tt> - The invoice number
  # * <tt>:merchant</tt> - The name or description of the merchant offering the product
  # * <tt>:description</tt> - A description of the transaction
  # * <tt>:email</tt> - The email address of the customer
  # * <tt>:currency</tt> - The currency of the transaction.  Only important when you are using a currency that is not the default with a gateway that supports multiple currencies.
  # * <tt>:billing_address</tt> - A hash containing the billing address of the customer.
  # * <tt>:shipping_address</tt> - A hash containing the shipping address of the customer.
  # 
  # The <tt>:billing_address</tt>, and <tt>:shipping_address</tt> hashes can have the following keys:
  # 
  # * <tt>:name</tt> - The full name of the customer.
  # * <tt>:company</tt> - The company name of the customer.
  # * <tt>:address1</tt> - The primary street address of the customer.
  # * <tt>:address2</tt> - Additional line of address information.
  # * <tt>:city</tt> - The city of the customer.
  # * <tt>:state</tt> - The state of the customer.  The 2 digit code for US and Canadian addresses. The full name of the state or province for foreign addresses.
  # * <tt>:country</tt> - The [ISO 3166-1-alpha-2 code](http://www.iso.org/iso/country_codes/iso_3166_code_lists/english_country_names_and_code_elements.htm) for the customer.
  # * <tt>:zip</tt> - The zip or postal code of the customer.
  # * <tt>:phone</tt> - The phone number of the customer.
  #
  # 439 recurring error fix
  def charge_credit_card
    # mode is set (in environment config files) to :test for development and test, :production when production
    if validate_card
      if product_cost.upfront_charge.zero?
        errors.add_to_base "One time fee: #{product_cose.upfront_charge}"
      else
        # one time charge as presented in the product detail box
        # charge_amount = (cost * 100) # cents
        #
        # reference from active_merchant code
        #
        # * <tt>purchase(money, creditcard, options = {})</tt>
        # * <tt>money</tt> -- The amount to be purchased as an Integer value in cents.
        # * <tt>creditcard</tt> -- The CreditCard details for the transaction.
        # * <tt>options</tt> -- A hash of optional parameters.
        @one_time_fee_response = GATEWAY.purchase( product_cost.upfront_charge*100, credit_card,
          :billing_address => {
            :first_name => bill_first_name,
            :last_name => bill_last_name,
            :address1 => bill_address,
            :phone => bill_phone,
            :city => bill_city,
            :state => bill_state,
            :zip => bill_zip,
            :country => "US",
            }
          ) # GATEWAY in environment files
        # store response in database
        payment_gateway_responses.create!(:action => "purchase", :amount => product_cost.upfront_charge*100, :response => @one_time_fee_response)
        errors.add_to_base @one_time_fee_response.message unless @one_time_fee_response.success?

        # recurring attempted only when one-time is success
        if @one_time_fee_response.success?
          if product_cost.monthly_recurring.zero?
            errors.add_to_base "Recurring subscription fee: #{product_cost.monthly_recurring}"
          else
            # https://redmine.corp.halomonitor.com/issues/2800
            # used credit_card.first_name instead of bill_first_name
            #
            # recurring subscription for 60 months, starting 3.months.from_now
            # TODO: do not hard code. pick from database
            # =>  keep charging 5 years at least
            #
            # reference from active_merchant code
            #
            # Create a recurring payment.
            #
            # This transaction creates a new Automated Recurring Billing (ARB) subscription. Your account must have ARB enabled.
            #
            # ==== Parameters
            #
            # * <tt>money</tt> -- The amount to be charged to the customer at each interval as an Integer value in cents.
            # * <tt>creditcard</tt> -- The CreditCard details for the transaction.
            # * <tt>options</tt> -- A hash of parameters.
            #
            # ==== Options
            #
            # * <tt>:interval</tt> -- A hash containing information about the interval of time between payments. Must
            #   contain the keys <tt>:length</tt> and <tt>:unit</tt>. <tt>:unit</tt> can be either <tt>:months</tt> or <tt>:days</tt>.
            #   If <tt>:unit</tt> is <tt>:months</tt> then <tt>:length</tt> must be an integer between 1 and 12 inclusive.
            #   If <tt>:unit</tt> is <tt>:days</tt> then <tt>:length</tt> must be an integer between 7 and 365 inclusive.
            #   For example, to charge the customer once every three months the hash would be
            #   +:interval => { :unit => :months, :length => 3 }+ (REQUIRED)
            # * <tt>:duration</tt> -- A hash containing keys for the <tt>:start_date</tt> the subscription begins (also the date the
            #   initial billing occurs) and the total number of billing <tt>:occurrences</tt> or payments for the subscription. (REQUIRED)
            #
            # requires!(options, :interval, :duration, :billing_address)
            # requires!(options[:interval], :length, [:unit, :days, :months])
            # requires!(options[:duration], :start_date, :occurrences)
            # requires!(options[:billing_address], :first_name, :last_name)
            # 
            @recurring_fee_response = GATEWAY.recurring(product_cost.monthly_recurring*100, credit_card, {
                :interval => {:unit => :months, :length => 1},
                :duration => {:start_date => product_cost.recurring_delay.from_now.to_date, :occurrences => 60},
                :billing_address => {
                  :first_name => bill_first_name,
                  :last_name => bill_last_name,
                  :address1 => bill_address,
                  :phone => bill_phone,
                  :city => bill_city,
                  :state => bill_state,
                  :zip => bill_zip,
                  :country => "US",
                  }
              }
            )
            # store response in database
            payment_gateway_responses.create!(:action => "recurring", :amount => product_cost.monthly_recurring*100, :response => @recurring_fee_response)
            errors.add_to_base @recurring_fee_response.message unless @recurring_fee_response.success?
          end # recurring
        end
        
      end # one time charge
    else
      # invalid card
      payment_gateway_responses.create!(:action => "validate_card", :amount => product_cost.upfront_charge*100, \
        :response => {:success => false, \
                      :authorization => "Authorization not attempted", \
                      :message => "Invalid card #{credit_card.display_number}", \
                      :params => credit_card.errors.full_messages.join(". ")})
    end # validate_card
    
    create_user_intake if card_successfully_charged? # card successful? then create user intake data
    
    # return @one_time_fee_response, @recurring_fee_response # more DRY. contained in Order
    card_successfully_charged? # return success/failure status as true/false
  end

  def card_successfully_charged?
    return (@one_time_fee_response.blank? || @recurring_fee_response.blank?) ? false : (@one_time_fee_response.success? && @recurring_fee_response.success?)
  end
  
  # reference from the active_merchant code
  #
  #   cc = CreditCard.new(
  #     :first_name => 'Steve', 
  #     :last_name  => 'Smith', 
  #     :month      => '9', 
  #     :year       => '2010', 
  #     :type       => 'visa', 
  #     :number     => '4242424242424242'
  #   )
  #
  # Optional verification_value (CVV, CVV2 etc). Gateways will try their best to 
  # run validation on the passed in value if it is supplied
  #
  def credit_card
    @card ||= ActiveMerchant::Billing::CreditCard.new(
      :first_name => bill_first_name,
      :last_name => bill_last_name,
      :month => card_expiry.month,
      :year => card_expiry.year,
      :type => card_type,
      :number => card_number,
      :verification_value => card_csc
    )
    # @card.extend ActiveMerchant::Billing::CreditCardMethods::ClassMethods
    # @card
  end
  
  def validate_card
    if credit_card.valid?
      return true
    else
      # [:expired?, :first_name?, :last_name?, :name?, 
      #   :requires_verification_value?, :verification_value?].each do |method_sym|
      #   credit_card.errors.add(method_sym.to_s) if credit_card.send(method_sym) == true
      # end
      # also add these errors to the AR for validation display
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
      return false
    end
  end
  
  def populate_billing_address
    if bill_address_same == "1"
      self.bill_first_name  = ship_first_name
      self.bill_last_name   = ship_last_name
      self.bill_address     = ship_address
      self.bill_city        = ship_city
      self.bill_state       = ship_state
      self.bill_zip         = ship_zip
      self.bill_email       = ship_email
      self.bill_phone       = ship_phone
    end
  end

  def assign_group(name)
    group_id = Group.find_or_create_by_name(name) # usually in a new order, so no need to check nil? zero?
  end

  # get invalid or expired warning messages for coupon code
  #  optionally pass "complete" or "clip" to skip order_items and check directly in table
  def message_for_coupon_code(which_code = coupon_code, product_type = "")
    messages = []
    if product_type.blank?      
      order_items.each {|order_item| messages << device_model_coupon_messages( order_item.device_model, which_code) }
    else
      messages << device_model_coupon_messages( DeviceModel.find_complete_or_clip(product_type), which_code)
    end
    messages.flatten.join(',')
  end
    
  # private methods
  #
  private
  
  def create_user_intake
    # this should only be created when
    # => credit card transaction is successful
    # => order is saved
    unless self.new_record? # user intake can be created only after save
      # TODO: DRYness required here
      senior_profile = { :first_name => ship_first_name, :last_name => ship_last_name, :address => ship_address, :city => ship_city, :state => ship_state, :zipcode => ship_zip, :home_phone => ship_phone }
      subscriber_profile = { :first_name => bill_first_name, :last_name => bill_last_name, :address => bill_address, :city => bill_city, :state => bill_state, :zipcode => bill_zip, :home_phone => bill_phone }
      user_intake = UserIntake.new
      user_intake.skip_validation = true # just save. even incomplete data
      user_intake.senior = User.new({:email => ship_email, :profile_attributes => senior_profile})
      if !subscribed_for_self? # when marked common or data common
        user_intake.subscriber_is_user = false
        user_intake.subscriber = User.new({:email => bill_email, :profile_attributes => subscriber_profile})
      end
      user_intake.order_id = self.id
      user_intake.save # database
      #
      # force manual emails dispatch here
      # Usually it will not send emails because skip_validation is "on"
      user_intake.senior.dispatch_emails # will dispatch only when user = halouser and valid email address
    end
  end
  
  def device_model_coupon_messages(device_model = nil, coupon_code = "")
    messages = []
    unless device_model.blank? || !device_model.is_a?( DeviceModel)
      price = device_model.prices.find_by_coupon_code(coupon_code)
      if price.blank?
        messages << coupon_code_message( device_model.model_type, "invalid")
      elsif price.expired?
        messages << coupon_code_message( device_model.model_type, "expired")
      end
    else
      messages << "Part number deprecated in product catalog. Please contact us with your order details." # at least some error should be shown
    end
    messages.flatten
  end
  
  def coupon_code_message(product_name = "myHalo product", status = "invalid")
    ["#{product_name}: This coupon is ", status, ". Regular pricing is applied."].join
  end
end
