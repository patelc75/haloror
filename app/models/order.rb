class Order < ActiveRecord::Base
  has_many :order_items
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  attr_accessor :card_csc, :product, :bill_address_same
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end

  # one time fee = from order
  # subscription = received as argument
  #
  def charge_one_time_and_subscription(one_time_fee, subscription_fee)
    return charge_credit_card(one_time_fee, subscription_fee)
    # one_time_fee = charge_one_time_fee(one_time_fee)
    # if !one_time_fee.blank? && one_time_fee.success?
    #   subscription = charge_subscription(subscription_fee)
    # end
    # return one_time_fee, subscription
  end
  
  def charge_one_time_fee(fee)
    charge_credit_card(fee, 0)
  end
  
  def charge_subscription(recurring_fee)
    charge_credit_card(0, recurring_fee)
  end
  
  def charge_credit_card(one_time_fee = 0, recurring_fee = 0)
    # mode is set (in environment config files) to :test for development and test, :production when production
    if validate_card
      unless one_time_fee.blank?
        # one time charge as presented in the product detail box
        charge_amount = (cost * 100) # cents
        @one_time_fee_response = GATEWAY.purchase(charge_amount, credit_card) # GATEWAY in environment files
      end
      
      unless recurring_fee.blank?
        # recurring subscription for 60 months, starting 3.months.from_now
        # TODO: do not hard code. pick from database
        # =>  keep charging 5 years at least
        @recurring_fee_response = GATEWAY.recurring(charge_amount, credit_card, {
            :billing_address => {:first_name => bill_first_name, :last_name => bill_last_name},
            :interval => {:unit => :months, :length => 1},
            :duration => {:start_date => 3.months.from_now.to_date, :occurrences => 60}
          }
        )
      end
    end
    return @one_time_fee_response, @recurring_fee_response
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :number => card_number,
      :month => card_expiry.month,
      :year => card_expiry.year,
      :first_name => bill_first_name,
      :last_name => bill_last_name,
      :type => card_type,
      :verification_value => card_csc
    )
  end
  
  def validate_card
    if credit_card.valid?
      return true
    else
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
      return false
    end
  end
  
  def populate_billing_address
    if bill_address_same == "1"
      bill_first_name = ship_first_name
      bill_last_name = ship_last_name
      bill_address = ship_address
      bill_city = ship_city
      bill_state = ship_state
      bill_zip = ship_zip
      bill_email = ship_email
      bill_phone = ship_phone
    end
  end

  def assign_group(name)
    group_id = Group.find_or_create_by_name(name) # usually in a new order, so no need to check nil? zero?
  end
end
