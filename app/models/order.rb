class Order < ActiveRecord::Base
  has_many :order_items
  has_many :payment_gateway_responses
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  attr_accessor :card_csc, :product, :bill_address_same
  
  def after_initialize
    self.bill_address_same = "1" if self.new_record?
    populate_billing_address # copy billing address if bill_address_same
  end
  
  # quick shortcut for the bill and ship address same
  def common_address
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

  # 439 recurring error fix
  def charge_credit_card
    # mode is set (in environment config files) to :test for development and test, :production when production
    if validate_card
      if product_cost.upfront_charge.zero?
        errors.add_to_base "One time fee: #{product_cose.upfront_charge}"
      else
        # one time charge as presented in the product detail box
        # charge_amount = (cost * 100) # cents
        @one_time_fee_response = GATEWAY.purchase(product_cost.upfront_charge*100, credit_card) # GATEWAY in environment files
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
            @recurring_fee_response = GATEWAY.recurring(product_cost.monthly_recurring*100, credit_card, {
                :billing_address => {:first_name => credit_card.first_name, :last_name => credit_card.last_name},
                :interval => {:unit => :months, :length => 1},
                :duration => {:start_date => product_cost.recurring_delay.from_now.to_date, :occurrences => 60}
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
    
    return @one_time_fee_response, @recurring_fee_response
  end

  def credit_card
    @card ||= ActiveMerchant::Billing::CreditCard.new(
      :number => card_number,
      :month => card_expiry.month,
      :year => card_expiry.year,
      :first_name => bill_first_name,
      :last_name => bill_last_name,
      :type => card_type,
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
