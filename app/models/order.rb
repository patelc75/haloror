class Order < ActiveRecord::Base
  has_many :order_items
  has_many :payment_gateway_responses
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  attr_accessor :card_csc, :product, :bill_address_same
  
  # validate coupon code when present. ignore when missing
  def validate_on_create
    record.errors.add :coupon_code, 'is not valid' \
      if DeviceModelPrice.count(:conditions => {:coupon_code => coupon_code}).zero? \
        unless coupon_code.blank?
  end
    
  # based on the above definitions
  def total_value
    value = 0
    order_items.each do |order_item|
      tariff = order_item.device_model.tariff(coupon_code) unless order_item.device_model.blank?
      value += (tariff.deposit + tariff.shipping + tariff.upfront_charge) unless tariff.blank?
    end
    value
  end
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end

  # one time fee = from order
  # subscription = received as argument
  #
  def charge_one_time_and_subscription_in_cents(one_time_fee, subscription_fee)
    one_time_response, subscription_response = charge_credit_card_in_cents(one_time_fee, subscription_fee)
    return one_time_response, subscription_response
  end
  
  # 439 recurring error fix
  def charge_credit_card_in_cents(one_time_fee_in_cents = 0, recurring_fee_in_cents = 0)
    # mode is set (in environment config files) to :test for development and test, :production when production
    if validate_card
      if one_time_fee_in_cents.zero?
        errors.add_to_base "One time fee: #{one_time_fee}"
      else
        # one time charge as presented in the product detail box
        # charge_amount = (cost * 100) # cents
        @one_time_fee_response = GATEWAY.purchase(one_time_fee_in_cents, credit_card) # GATEWAY in environment files
        # store response in database
        payment_gateway_responses.create!(:action => "purchase", :amount => one_time_fee_in_cents, :response => @one_time_fee_response)
        errors.add_to_base @one_time_fee_response.message unless @one_time_fee_response.success?

        #
        # recurring should be attempted only when one-time is charged
        #
        
        if recurring_fee_in_cents.zero?
          errors.add_to_base "Recurring subscription fee: #{recurring_fee}"
        else
          # recurring subscription for 60 months, starting 3.months.from_now
          # TODO: do not hard code. pick from database
          # =>  keep charging 5 years at least
          @recurring_fee_response = GATEWAY.recurring(recurring_fee_in_cents, credit_card, {
              :billing_address => {:first_name => bill_first_name, :last_name => bill_last_name},
              :interval => {:unit => :months, :length => 1},
              :duration => {:start_date => 3.months.from_now.to_date, :occurrences => 60}
            }
          )
          # store response in database
          payment_gateway_responses.create!(:action => "recurring", :amount => recurring_fee_in_cents, :response => @recurring_fee_response)
          errors.add_to_base @recurring_fee_response.message unless @recurring_fee_response.success?
        end # recurring
        
      end # one time charge
    else
      # invalid card
      payment_gateway_responses.create!(:action => "validate_card", :amount => one_time_fee_in_cents, \
        :response => {:success => false, \
                      :authorization => "Authorization not attempted", \
                      :message => "Invalid card #{credit_card.display_number}", \
                      :params => credit_card.errors.full_messages.join(". ")})
    end # validate_card
    
    return @one_time_fee_response, @recurring_fee_response
  end

  def credit_card
    @card ||= ActiveMerchant::Billing::CreditCard.new(
      :number => self.card_number,
      :month => self.card_expiry.month,
      :year => self.card_expiry.year,
      :first_name => self.bill_first_name,
      :last_name => self.bill_last_name,
      :type => self.card_type,
      :verification_value => self.card_csc
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
    if self.bill_address_same == "1"
      self.bill_first_name  = self.ship_first_name
      self.bill_last_name   = self.ship_last_name
      self.bill_address     = self.ship_address
      self.bill_city        = self.ship_city
      self.bill_state       = self.ship_state
      self.bill_zip         = self.ship_zip
      self.bill_email       = self.ship_email
      self.bill_phone       = self.ship_phone
    end
  end

  def assign_group(name)
    group_id = Group.find_or_create_by_name(name) # usually in a new order, so no need to check nil? zero?
  end
end
