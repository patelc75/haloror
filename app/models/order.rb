class Order < ActiveRecord::Base
  has_many :order_items
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  validate_on_create :validate_card
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end
  
  def charge_one_time_fee
    charge_credit_card
  end
  
  def charge_subscription
    charge_credit_card("recurring")
  end
  
  def charge_credit_card(recurring = nil) # default is one-time-charge. any value for recurring will work.
    ActiveMerchant::Billing::Base.mode = Rails.env.to_sym # only process in production

    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number => card_number,
      :month => card_expiry.month,
      :year => card_expiry.year,
      :first_name => bill_first_name,
      :last_name => bill_last_name,
      :type => card_type
    )
    
    if credit_card.valid?
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
        :login => AUTH_NET_LOGIN,
        :password => AUTH_NET_TXN_KEY
      )
      if recurring.blank?
        # one time charge as presented in the product detail box
        #
        charge_amount = (cost * 100) # cents
        @response = gateway.purchase(charge_amount, credit_card)
      else
        # recurring subscription for 60 months, starting 3.months.from_now
        # TODO: do not hard code. pick from database
        #
        charge_amount = (session[:product] == "complete" ? 5900 : 4900) # cents
        @response = gateway.recurring(charge_amount, credit_card, {
            :interval => {:unit => :months, :interval => 1},
            :duration => {:start_date => 3.months.from_now, :occurences => 60} # keep charging 5 years at least
          }
        )
      end
      @response
    end
  end

  # include vaidation errors in controller
  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end
  
end
