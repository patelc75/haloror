class Order < ActiveRecord::Base
  has_many :order_items
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  attr_accessor :card_csc, :product, :bill_address_same
#  validate_on_create :validate_card
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end
  
  def charge_one_time_fee
    charge_credit_card
  end
  
  def charge_subscription(charge_amount)
    charge_credit_card("recurring",charge_amount)
  end
  
  def charge_credit_card(recurring = nil, charge_amount = 0) # default is one-time-charge. any value for recurring will work.
    # mode is set (in environment config files) to :test for development and test, :production when production
    if credit_card.valid?
      if recurring.blank?
        # one time charge as presented in the product detail box
        charge_amount = (cost * 100) # cents
        @response = GATEWAY.purchase(charge_amount, credit_card) # GATEWAY in environment files
      else
        # recurring subscription for 60 months, starting 3.months.from_now
        # TODO: do not hard code. pick from database
        # =>  keep charging 5 years at least
        @response = GATEWAY.recurring(charge_amount, credit_card, {
            :billing_address => {:first_name => bill_first_name, :last_name => bill_last_name},
            :interval => {:unit => :months, :length => 1},
            :duration => {:start_date => 3.months.from_now.to_date, :occurrences => 60}
          }
        )
      end
      @response
    end
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
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end
end
