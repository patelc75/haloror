# require "lib/utility_helper"

class Order < ActiveRecord::Base
  include UtilityHelper
  
  belongs_to :group
  # belongs_to :affiliate_fee_group, :class_name => "Group"
  # belongs_to :referral_group, :class_name => "Group"
  # belongs_to :device_model_price, :class_name => "DeviceModelPrice", :foreign_key => "coupon_code_id"
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  # 
  #  Wed Mar  9 01:01:27 IST 2011, ramonrails
  #   * coupon code changes for tickets #4253, #4067, #4060, #3923
  belongs_to :shipping_option
  has_many :order_items
  has_many :payment_gateway_responses
  has_one :user_intake
  has_one :device_model

  attr_accessor :product, :bill_address_same, :need_validation
  before_update :check_kit_serial_validation

  validates_presence_of :group, :unless => :skip_validation?
  
  named_scope :ordered, lambda { |*args| { :order => (args.blank? ? 'created_at DESC' : args.flatten.first.to_s) } }
  
  # causing failure of order. need to force kit_serial for retailer in some other way
  # validates_presence_of :kit_serial, :if => :retailer?
  
  # ===================================
  # = triggers / active record events =
  # ===================================
  
  def after_initialize
    self.coupon_code = "default" if coupon_code.blank?
    populate_billing_address # copy billing address if bill_address_same
    # 
    #  Fri Dec  3 01:13:31 IST 2010, ramonrails
    #   * laod product type, if applicable
    #   * self.product attribute not touched for new record anyways
    load_product_type unless new_record?
    #
    # WARNING: some error happening. switched off for now. needs testing
    decrypt_sensitive_data # Will decrypt only if encrypted?
  end

  def before_save
    #
    # WARNING: some error happening. switched off for now. needs testing
    encrypt_sensitive_data # Will encrypt only if not already encrypted?
    # 
    #  Sat Mar 12 02:14:06 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4253
    #   * copy coupon code data to order
    _coupon = product_cost
    self.device_model_id      = _coupon.device_model.id
    self.cc_expiry_date       = _coupon.expiry_date
    self.cc_deposit           = _coupon.deposit
    self.cc_shipping          = _coupon.shipping
    self.cc_monthly_recurring = _coupon.monthly_recurring
    self.cc_months_advance    = _coupon.months_advance
    self.cc_months_trial      = _coupon.months_trial
    # 
    #  Tue Mar 15 03:01:33 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4060
    if _coupon.shipping.to_i == 0
      unless shipping_option.blank?
        self.ship_description = shipping_option.description
        self.ship_price       = shipping_option.price
      end
    else
      self.ship_description = "Coupon Code: #{coupon_code}"
      self.ship_price       = _coupon.shipping
    end
  end
  
  def validate
    # 
    #  Mon Mar  7 23:27:25 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4248
    coupon_code_valid?
  end

  # =============================
  # = public : instance methods =
  # =============================

  # 
  #  Mon Mar  7 23:07:53 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4248
  def coupon_code_valid?
    _coupon = product_cost # fetch the coupon code applicable for the selected group
    errors.add_to_base( "Coupon code #{coupon_code} is not valid for the group #{group_name}") if _coupon.blank? || (_coupon.coupon_code != coupon_code)
    errors.add_to_base( "Coupon code expired on #{_coupon.expiry_date}") if _coupon.expired?
    ( !_coupon.blank? && !_coupon.expired? ) # valid?
  end
  
  # 
  #  Tue Jan 11 01:54:22 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3988
  def skip_validation?
    !need_validation
  end
  
  # 
  #  Tue Jan 11 01:54:22 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3988
  def skip_validation=( _action = true)
    self.need_validation = !_action
  end

  # 
  #  Fri Dec 31 02:56:24 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3951
  def coupon_details_as_hash
    # 
    #  Thu Jan 27 21:47:44 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4101
    #   * coupon code should be picked with the applied business logic
    #   * confirmed in browser with a temporary change on dfw-web3. ticket updated with details
    #   * just picking the first one is not appropriate
    if ( _coupon = product_cost )
    # if order_items && order_items.first.device_model && order_items.first.device_model.coupon_codes
    #   _coupon = order_items.first.device_model.coupon_codes.first
      { "code name" => _coupon.coupon_code, "deposit" => _coupon.deposit, "shipping" => _coupon.shipping, "monthly_recurring" => _coupon.monthly_recurring, "months_advance" => _coupon.months_advance, "months_trial" => _coupon.months_trial }
    else                           
     {} 
    end
  end
  
  # 
  #  Tue Dec 28 21:24:08 IST 2010, ramonrails
  #   * check payment_gateway_responses for any failed transactions
  def has_failed_transactions?
    !payment_gateway_responses.failed.blank?
  end

  # send order summary email to the master group, only when applicable
  def send_summary_to_group_and_master_group
    # group must be present
    # master group must be present
    #   * group name should be xx_...
    #   * master group with name xx_master must exist
    _master_group = group.master_group unless group.blank? 
    UserMailer.deliver_order_summary( self, group.email ) if !group.blank?
    UserMailer.deliver_order_summary( self, _master_group.email ) if !_master_group.blank? && _master_group.valid?
  end
  # ----------- new, updated method below ------------------
  # 
  #  Mon Dec 20 23:04:50 IST 2010, ramonrails
  #   * send emails to group, group admins, master group
  # # send order summary email to the master group, only when applicable
  # def send_summary_to_group_and_related
  #   # group must be present
  #   # master group must be present
  #   #   * group name should be xx_...
  #   #   * master group with name xx_master must exist
  #   unless group.blank?
  #     _master_group = group.master_group
  #     #   * group
  #     # UserMailer.deliver_order_summary( self, group.email )
  #     #   * group admins
  #     _emails = [ group.email, group.has_admins.collect(&:email) ]
  #     #   * master group
  #     _emails += _master_group.email if ( !_master_group.blank? && _master_group.valid? )
  #     #   * dispatch to all collected emails
  #     _emails.compact.uniq.each { |_email| UserMailer.deliver_order_summary( self, _email ) }
  #   end
  # end

  def group_name
    group.blank? ? "" : group.name
  end

  def reseller?
    group.blank? ? false : group.is_reseller?
  end
  
  def retailer?
    group.blank? ? false : group.is_retailer?
  end
  
  def check_kit_serial_validation
    # self.errors.add_to_base("Please provide the Kit Serial Number") if need_to_force_kit_serial?
  end
  
  def need_to_force_kit_serial?
    # WARNING: need to confirm this business logic
    #   At other places in the code, kit_serial is forced for both retailer & reseller
    #   so, this was updated on Mon Sep 20 23:23:44 IST 2010
    false # (retailer? || reseller?) && self.kit_serial.blank?
  end
  
  # quick shortcut for the bill and ship address same
  def subscribed_for_self?
    (["1", true ].include?( bill_address_same) || ship_and_bill_address_match)
  end
    
  # find out if the product catalog has the product from HASH
  def product_from_catalog
    @product_found_in_catalog ||= DeviceModel.find_complete_or_clip( product) # cache
  end
  
  # tariff card for the product found in catalog
  def product_cost
    product_from_catalog.coupon( :group => (group || Group.direct_to_consumer), :coupon_code => coupon_code)
  end
  
  # create order_item enteries for this order
  def create_order_items
    device_model = product_from_catalog
    _cost = product_cost
    # create a recurring order item
    if order_items.create({
        :cost              => _cost.monthly_recurring,
        :quantity          => 1,
        :recurring_monthly => true,
        :device_model_id   => device_model.id
      })
      # 
      #  Thu Mar 17 01:00:16 IST 2011, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/3923
      # create order item for each product charge
      [_cost.deposit, _cost.shipping, _cost.advance_charge, _cost.dealer_install_fee].each do |_amount|
        unless _amount.zero?
          if order_items.create!({
              :device_model_id => device_model.id,
              :cost            => _amount,
              :quantity        => 1
            })
          else
            errors.add_to_base( "Cannot create charge for #{USD_value(_amount)}")
          end
        end
      end
    else
      errors.add_to_base( "Cannot create monthly recurring order item #{USD_value(_cost.monthly_recurring)}")
    end
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
      tariff = order_item.device_model.coupon( :group => group, :coupon_code => coupon_code) unless order_item.device_model.blank?
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
  def charge_credit_card( options = {})
    # mode is set (in environment config files) to :test for development and test, :production when production
    #
    # charges pro-rata or upfront
    if options.blank? # no options means charge upfront
      _cost = (product_cost.blank? ? 0 : product_cost.upfront_charge)
      # 
      #  Thu Nov 25 00:18:02 IST 2010, ramonrails
      #   * "purchase" changed
      _action = "deposit + shipping"
    else
      _cost = options[ :pro_rata]
      _action = "pro-rata"
    end
    #
    if validate_card
      if product_cost.blank?
        errors.add_to_base "Product cost cannot be identified in the database"
      # 
      #  Wed Dec  1 02:37:38 IST 2010, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/3805
      #   * zero one-time-fee is possible with certain coupon codes
      #   * therefore, absolutely zero charge at online order
      #   * subscription & pro-rata charged later as usual
      #   OBSOLETE: the logic now accepts zero value charges
      # elsif product_cost.upfront_charge.zero?
      #   errors.add_to_base "One time fee: #{product_cost.upfront_charge}"
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
        @one_time_fee_response = payment_gateway_server.purchase( _cost*100, credit_card,
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
        payment_gateway_responses.create!(:action => _action, :amount => _cost*100, :response => @one_time_fee_response)
        errors.add_to_base @one_time_fee_response.message unless @one_time_fee_response.success?

        # ticket 3215: Credit card will no longer be charged recurring monthly at the point of sale (when order is taken)
        #   * shifted to charge_recurring
        #   * added purchase_successful?, subscription_successful?, charge_subscription
        #
        # # recurring attempted only when one-time is success
        # if @one_time_fee_response.success?
        #   # if product_cost.monthly_recurring.zero?
        #   #   errors.add_to_base "Recurring subscription fee: #{product_cost.monthly_recurring}"
        #   # else
        #   #   # https://redmine.corp.halomonitor.com/issues/2800
        #   #   # used credit_card.first_name instead of bill_first_name
        #   #   #
        #   #   # recurring subscription for 60 months, starting 3.months.from_now
        #   #   # TODO: do not hard code. pick from database
        #   #   # =>  keep charging 5 years at least
        #   #   #
        #   #   # reference from active_merchant code
        #   #   #
        #   #   # Create a recurring payment.
        #   #   #
        #   #   # This transaction creates a new Automated Recurring Billing (ARB) subscription. Your account must have ARB enabled.
        #   #   #
        #   #   # ==== Parameters
        #   #   #
        #   #   # * <tt>money</tt> -- The amount to be charged to the customer at each interval as an Integer value in cents.
        #   #   # * <tt>creditcard</tt> -- The CreditCard details for the transaction.
        #   #   # * <tt>options</tt> -- A hash of parameters.
        #   #   #
        #   #   # ==== Options
        #   #   #
        #   #   # * <tt>:interval</tt> -- A hash containing information about the interval of time between payments. Must
        #   #   #   contain the keys <tt>:length</tt> and <tt>:unit</tt>. <tt>:unit</tt> can be either <tt>:months</tt> or <tt>:days</tt>.
        #   #   #   If <tt>:unit</tt> is <tt>:months</tt> then <tt>:length</tt> must be an integer between 1 and 12 inclusive.
        #   #   #   If <tt>:unit</tt> is <tt>:days</tt> then <tt>:length</tt> must be an integer between 7 and 365 inclusive.
        #   #   #   For example, to charge the customer once every three months the hash would be
        #   #   #   +:interval => { :unit => :months, :length => 3 }+ (REQUIRED)
        #   #   # * <tt>:duration</tt> -- A hash containing keys for the <tt>:start_date</tt> the subscription begins (also the date the
        #   #   #   initial billing occurs) and the total number of billing <tt>:occurrences</tt> or payments for the subscription. (REQUIRED)
        #   #   #
        #   #   # requires!(options, :interval, :duration, :billing_address)
        #   #   # requires!(options[:interval], :length, [:unit, :days, :months])
        #   #   # requires!(options[:duration], :start_date, :occurrences)
        #   #   # requires!(options[:billing_address], :first_name, :last_name)
        #   #   # 
        #   #   # https://redmine.corp.halomonitor.com/issues/3068
        #   #   # recurring start_date was immediate. ".months" was missed in last release
        #   #   
        #   #   @recurring_fee_response = ::PAYMENT_GATEWAY.recurring(product_cost.monthly_recurring*100, credit_card, {
        #   #       :interval => {:unit => :months, :length => 1},
        #   #       :duration => {:start_date => product_cost.recurring_delay.months.from_now.to_date, :occurrences => 60},
        #   #       :billing_address => {
        #   #         :first_name => bill_first_name,
        #   #         :last_name => bill_last_name,
        #   #         :address1 => bill_address,
        #   #         :phone => bill_phone,
        #   #         :city => bill_city,
        #   #         :state => bill_state,
        #   #         :zip => bill_zip,
        #   #         :country => "US",
        #   #         }
        #   #     }
        #   #   )
        #   #   store response in database
        #   #   payment_gateway_responses.create!(:action => "recurring", :amount => product_cost.monthly_recurring*100, :response => @recurring_fee_response)
        #   #   errors.add_to_base @recurring_fee_response.message unless @recurring_fee_response.success?
        #   # end # recurring
        # end
        
      end # one time charge
    else
      # invalid card
      payment_gateway_responses.create!(:action => "validate_card", :amount => _cost*100, \
        :response => {:success => false, \
                      :authorization => "Authorization not attempted", \
                      :message => "Invalid card #{credit_card.display_number}", \
                      :params => credit_card.errors.full_messages.join(". ")})
    end # validate_card
    
    # 
    #  Fri Nov  5 06:55:50 IST 2010, ramonrails
    #  do not create a userintake if already present
    create_user_intake if card_successful? && user_intake.blank? # card successful? then create user intake data
    
    # return @one_time_fee_response, @recurring_fee_response # more DRY. contained in Order
    card_successful? # return success/failure status as true/false
  end

  def card_successful?
    # 
    #  Wed Dec  1 02:57:13 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3805
    #   * order can be successful with an invalid amount also
    # when instance variables are blank? this might be a successful saved order. check payment_gateway_responses
    return (@one_time_fee_response.blank?) ? purchase_successful? : (@one_time_fee_response.success? || @one_time_fee_response.message.include?('valid amount is required'))
    # return (@one_time_fee_response.blank? || @recurring_fee_response.blank?) ? purchase_successful? : (@one_time_fee_response.success? && @recurring_fee_response.success?)
  end
  
  def purchase_successful?
    # for existing order, check the stored values from gateway responses
    # this works for new_record? also because the responses would be blank
    !payment_gateway_responses.purchase.successful.blank? # blank = false, when_found = true
    # !payment_gateway_responses.blank? && payment_gateway_responses.all?(&:success)
  end
  
  # https://redmine.corp.halomonitor.com/issues/3215
  #   business logic updated to charge credit card on clicking credit_card icon in user intake list, after successful installation
  #   this will verify if recurring charges were applied?
  # 
  #  Fri Nov  5 06:15:23 IST 2010, ramonrails
  #  WARNING: This is a very risky method. What about continued subscriptions?
  def subscription_successful?
    !payment_gateway_responses.subscription.successful.blank? # row found = true, nil = false
  end
  
  # 
  #  Wed Feb 16 00:35:22 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4199
  def subscription_started_at
    if (_row = payment_gateway_responses.subscription.successful.all( :order => 'created_at ASC').first)
      Time.parse( Hash.from_xml( _row.request_data)["hash"]["ARBCreateSubscriptionRequest"]["subscription"]["paymentSchedule"]["startDate"])
    end
  end

  # 
  #  Fri Dec  3 02:25:50 IST 2010, ramonrails
  #   * check if pro-rata was already successful
  def pro_rata_successful?
    !payment_gateway_responses.pro_rata.successful.blank?
  end
  
  # http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=2
  # * subscrition for DTC is now charged from 1st of next month
  # * pro-rata chargeed since installed date or, 7 calendar days from shipped
  def charge_subscription # ( days = nil)
    # _success = false # default
    # 
    #  Wed Dec  1 23:17:57 IST 2010, ramonrails
    #   * recurring should be charged multiple times
    #   * subscription_successful? logic will only charge it once
    # # recurring attempted only when one-time is success
    # if purchase_successful? && subscription_successful?
    #   # 
    #   #  Fri Nov  5 06:31:05 IST 2010, ramonrails
    #   #  If both charges are received, return true
    #   _success = true
    # else
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
      # https://redmine.corp.halomonitor.com/issues/3068
      # recurring start_date was immediate. ".months" was missed in last release
      #
      # product_cost.recurring_delay.months.from_now.to_date
      # 
      #  Tue Nov 23 01:11:03 IST 2010, ramonrails
      #   * subscription is charged from today if month started today
      #   * subscription starts from next month if we are already within this month
      _date = user_intake.subscription_start_date
      _date = _date.to_date unless _date.blank? # consider 'nil' values too
      # 
      #  Thu Dec  2 00:33:46 IST 2010, ramonrails
      #   * this logic shifted to subscription_start_date
      # _date = if (_date.day == 1) # beginning of the month
      #   _date
      # else
      #   (_date + 1.month).beginning_of_month.to_date
      # end
      @recurring_fee_response = payment_gateway_server.recurring(product_cost.monthly_recurring*100, credit_card, {
        :interval => {:unit => :months, :length => 1},
        :duration => {:start_date => _date, :occurrences => 60},
        :billing_address => {
          :first_name => bill_first_name,
          :last_name  => bill_last_name,
          :address1   => bill_address,
          :phone      => bill_phone,
          :city       => bill_city,
          :state      => bill_state,
          :zip        => bill_zip,
          :country    => "US",
        }
      }
      )
      # store response in database
      payment_gateway_responses.create!(:action => "recurring", :amount => product_cost.monthly_recurring*100, :response => @recurring_fee_response)
      errors.add_to_base @recurring_fee_response.message unless @recurring_fee_response.success?
      # _success = @recurring_fee_response.success?
    end # recurring
    # end
    # _success
    (defined?(@recurring_fee_response) && @recurring_fee_response.success?)
  end
  
  def charge_pro_rata
    #
    # difference of days since desired installation date and now
    #  Tue Nov 23 01:03:39 IST 2010, ramonrails
    #   * pro-rata includes both dates defining the boundaries. add +1 to include them
    #   * On 1st of the month, do not pro-rate
    #  Fri Dec  3 02:28:24 IST 2010, ramonrails
    #   * do not charge if pro-rata was already charged
    _date = user_intake.pro_rata_start_date
    if _date.blank? || (_date.day == 1) || pro_rata_successful?
      #   * we just return true for the dependent logic
      #   * we do not charge pro-rata if today is the first of the month
      true

    else
      # 
      #  Mon Feb  7 23:53:48 IST 2011, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/4155
      # #
      # # assuming the cost is for 30 days (one month)
      # # CHANGED:
      # #   DO NOT remove the decimals. if monthly recurring is less than 30, this will return ZERO
      # _per_day_cost = (product_cost.monthly_recurring / 30.00)
      # #   * calculate number of days
      # #   * charge card
      # _number_of_days = (_date.end_of_month.day - _date.day + 1)
      #
      # charge pro-rata for the period
      # 
      #  Fri Nov  5 07:25:43 IST 2010, ramonrails
      #  both values here must be 2 decimals, for correct calculation
      charge_credit_card( :pro_rata => pro_rated_amount )
    end
  end

  # 
  #  Mon Feb  7 23:53:43 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4155
  #  Fri Mar  4 03:20:57 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4215
  def pro_rated_amount
    _start = user_intake.pro_rata_start_date
    _stop  = user_intake.subscription_start_date

    unless _start.blank? || _stop.blank?
      #   * calculate month specific cost
      #   * WARNING: do not use "round". It will give incorrect results
      _months_diff = ((_stop - _start) / 1.month).to_i # to_i will show sandwitched complete months
      _cost        = product_cost.monthly_recurring
      _amount      = 0 # default

      #   * same month. we want "round" here to keep "both days inclusive"
      #   * just get the difference between two dates
      if _start.end_of_month == _stop.end_of_month
        _days       = ((_stop - _start) / 1.day).round
        _daily_cost = (_cost / (_stop.end_of_month.day * 1.00)) # per day cost for this month
        _amount     = (_days * _daily_cost).round(2)
      else


        #   * start and 
        #   * start = last month, end = this month
        #   last month
        _days       = ((_start.end_of_month - _start) / 1.day).round # include both days
        _daily_cost = (_cost / (_start.end_of_month.day * 1.00)) # per day cost for this month
        _amount     += (_days * _daily_cost).round(2)
        #   this month
        _days       = ((_stop - _stop.beginning_of_month) / 1.day).round # include both days
        _daily_cost = (_cost / (_stop.end_of_month.day * 1.00)) # per day cost for this month
        _amount     += (_days * _daily_cost).round(2)
        
        #   * now add any "complete" months that were between these dates
        #   * _months_diff is calculated via "to_i", which excludes months of start, stop dates
        #   * only complete months are counted here. no start ot stop dates occur between them
        #   * 1.00 is just to make the value for 2 decimal places
        _amount += (_months_diff * _cost * 1.00).round(2)
        
      end
    end
    # if ( _date = user_intake.pro_rata_start_date)
    #   #
    #   # assuming the cost is for 30 days (one month)
    #   # CHANGED:
    #   #   DO NOT remove the decimals. if monthly recurring is less than 30, this will return ZERO
    #   _per_day_cost = (product_cost.monthly_recurring / 30.00).round(2)
    #   #   * calculate number of days
    #   #   * charge card
    #   _number_of_days = user_intake.pro_rated_days # (_date.end_of_month.day - _date.day + 1)
    #   #   * return the pro-rata amount applicable
    #   _per_day_cost * _number_of_days
    # end
  end

  def masked_card_number
    '****' + ( card_number.blank? ? '' : card_number.to_s[-4..-1] ) # fetch last 4 characters
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
  #  Wed Nov 10 02:38:28 IST 2010, ramonrails
  #  CVV is *not* optional for authorize.net at least
  #   We had to create a temporary cvv column in orders table earlier to shift to CIM token system
  #
  def credit_card
    #
    # Thu Sep 16 20:06:15 IST 2010 > https://redmine.corp.halomonitor.com/issues/3419#note-7
    #   card number was accessed before the initialization completed
    #   this step ensures card_number in plain text state
    decrypt_sensitive_data # does not harm if run more than once
    # 
    #  Fri Nov  5 07:37:01 IST 2010, ramonrails
    #   We do not have the CSC/CVV code at the time of "Bill"
    #   We are going to store it "encrypted" until we shift to CIM token system
    @card ||= ActiveMerchant::Billing::CreditCard.new( {
      :first_name => bill_first_name,
      :last_name => bill_last_name,
      :month => card_expiry.month,
      :year => card_expiry.year,
      :type => card_type,
      :number => card_number,
      :verification_value => cvv })
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

  # CHANGED: Mon Sep 20 22:53:40 IST 2010
  #   Now user: Group.direct_to_consumer
  #
  # def assign_group(name)
  #   group_id = Group.find_or_create_by_name(name) # usually in a new order, so no need to check nil? zero?
  # end

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

  def need_agreement_sign?
    user_intake.blank? ? false : user_intake.legal_agreement_at.blank?
  end
  
  # ===================
  # = private methods =
  # ===================

  private
  
  # 
  #  Fri Dec  3 01:09:05 IST 2010, ramonrails
  #   * works at reload of order
  #   * self.product attribute not touched for new_record
  def load_product_type
    unless order_items.blank? || order_items.first.device_model.blank?
      _type = case order_items.first.device_model.part_number
      when '12001008-1'; 'clip';
      when '12001002-1'; 'complete';
      end
      self.product ||= _type
    end
  end
  
  def create_user_intake
    # this should only be created when
    # => credit card transaction is successful
    # => order is saved
    if (self.created_at == self.updated_at) && user_intake.blank? # user intake can be created only after save
      # TODO: DRYness required here
      senior_profile = { :first_name => ship_first_name, :last_name => ship_last_name, :address => ship_address, :city => ship_city, :state => ship_state, :zipcode => ship_zip, :home_phone => ship_phone }
      subscriber_profile = { :first_name => bill_first_name, :last_name => bill_last_name, :address => bill_address, :city => bill_city, :state => bill_state, :zipcode => bill_zip, :home_phone => bill_phone }
      #   * build... assigns order id automatically
      self.build_user_intake # user_intake = UserIntake.new
      # 
      #  Thu Mar 24 00:58:45 IST 2011, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/4291
      user_intake.device_model_size = device_model_size
      user_intake.group = group # halouser role is for group
      user_intake.senior_attributes = {:email => ship_email, :profile_attributes => senior_profile}
      #
      # when senior and subscriber are different, then subscriber is also the caregiver
      user_intake.subscriber_is_user = subscribed_for_self?
      # subscriber cannot be user and acregiver at the same time
      user_intake.subscriber_is_caregiver = !user_intake.subscriber_is_user
      user_intake.subscriber_attributes = {:email => bill_email, :profile_attributes => subscriber_profile}
      #
      #   * This is processed inside user intake
      # user_intake.bill_monthly = false # paid through card already
      # user_intake.credit_debit_card_proceessed = true # we received online payment through a card
      #
      # QUESTION: should we have gateway and transmitter serials derived from kit serial here?
      user_intake.kit_serial_number = self.kit_serial
      user_intake.order_id = self.id
      user_intake.created_by = self.created_by # https://redmine.corp.halomonitor.com/issues/3117
      user_intake.updated_by = self.updated_by
      user_intake.skip_validation = true # just save. even incomplete data
      user_intake.save # database
      # 
      #  Thu Nov 11 00:51:52 IST 2010, ramonrails
      #  This caused a ghost row in users table if caregivers were just blank records in UI
      #  Now shifted to user_intake.associations_after_save
      #  * This means active/away - the role, not active/login-password - the account
      #  * user_intake.caregivers.each(&:activate) # https://redmine.corp.halomonitor.com/issues/3117
      #  * OBSOLETE: refer to user intake states spreadsheet
      #
      # CHANGED: dispatch emails now goes to user.rb
      # #
      # # force manual emails dispatch here
      # # Usually it will not send emails because skip_validation is "on"
      # user_intake.senior.dispatch_emails # will dispatch only when user = halouser and valid email address
    end
  end
  
  def device_model_coupon_messages(device_model = nil, coupon_code = "")
    messages = []
    unless device_model.blank? || !device_model.is_a?( DeviceModel)
      price = device_model.coupon_codes.find_by_coupon_code(coupon_code)
      # 
      #  Wed Nov 10 02:53:22 IST 2010, ramonrails
      #  https://redmine.corp.halomonitor.com/issues/3693
      if price.blank? # || (price.coupon_code != coupon_code) || (group.coupon_codes.find_by_coupon_code(coupon_code).blank?)
        # messages << coupon_code_message( device_model.model_type, "invalid")
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

  public
  
  def encrypt_sensitive_data
    #
    # TODO: WARNING: We need to cover this with cucumber before release
    #   All required steps are already taken to make sure data is not lost
    #   BUT, we still need to test it before releasing
    #
    # Keep data Base64 encoded to prevent any loss during conversion process
    self.card_number = Base64.encode64( encryption_key.encrypt( card_number.to_s)) if need_encryption?
    # TODO: we must switch to CIM token process instead of encrypted CVV value, as soon as possible
    # TODO: can be more DRY in a loop
    self.cvv = Base64.encode64( encryption_key.encrypt( cvv.to_s)) if need_encryption?( cvv)
  rescue Exception => e
    #  Tue Dec 28 00:09:05 IST 2010, ramonrails
    #   * send email for any error
    OrderMailer.deliver_encryption_decryption_exception( self, e.message)
  end
  
  def decrypt_sensitive_data
    #
    # TODO: WARNING: We need to cover this with cucumber before release
    #   All required steps are already taken to make sure data is not lost
    #   BUT, we still need to test it before releasing
    #
    # Keep data Base64 encoded to prevent any loss during conversion process
    self.card_number = encryption_key.decrypt( Base64.decode64( card_number.to_s)) if encrypted?
    # TODO: we must switch to CIM token process instead of encrypted CVV value, as soon as possible
    # TODO: can be more DRY in a loop
    self.cvv = encryption_key.decrypt( Base64.decode64( cvv.to_s)) if encrypted?( cvv)
  rescue Exception => e
    #  Tue Dec 28 00:09:05 IST 2010, ramonrails
    #   * send email for any error
    OrderMailer.deliver_encryption_decryption_exception( self, e.message)
  end
  
  def encryption_key
    #
    # generate random salt for each credit card
    # takes Time.now and adds random amount of seconds to it, up to 10 place values
    #   * WARNING: do not use "||=". blank? checks for empty strings, ||= does not
    self.salt = Base64.encode64( (Time.now + rand(9999999999).seconds).to_s )[0..56] if salt.blank?
    #
    # generate key from the salt, unless buffered
    @_encryption_key ||= EzCrypto::Key.with_password( "HaloROR-Encryption", salt, :algorithm => "blowfish") # this generates the key
  end

  # 
  #  Tue Nov  9 21:46:51 IST 2010, ramonrails
  #  default: check card_number column
  #      arg: check given value. (For example: cvv column)
  def encrypted?( arg = card_number)
    # WARNING: A missing or deleted salt (for any reason) can cause card data unusable
    #   This ensures safety of card user also
    # To identify if the card number is encrypted
    #   * card number is not just plain all digits
    #   * salt exists (not a robust idea. this can be removed by external factors also)
    #   * match data with regex [A-Za-z0-9+\/]+={0,3}
    #   * converting to_i and original values should not match
    #   * WARNING: -- do not check --, length is divisible by 4
    #   * WARNING: -- do not check --, arg.to_i == 0
    arg = arg.to_s
    !arg.blank? && arg.match(/^[A-Za-z0-9+\/]+={0,3}$/) && !arg.match(/^(\d+)$/) && (arg.to_i.to_s != arg) && !salt.blank? # && (arg.length % 4).zero?
  end
  
  def need_encryption?( arg = card_number)
    !arg.blank? && !encrypted?( arg)
  end
end
