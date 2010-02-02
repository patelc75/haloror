
class Order < ActiveRecord::Base
  has_many :order_items
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :updater, :class_name => 'User', :foreign_key => 'updated_by'
  
  # order number : YYYYMMDD-id
  #
  def full_number
    "#{created_at.to_date.to_s(:number)}-#{id}"
  end
  
  def charge_credit_card
    charge_amount = (cost * 100) # cents
    login = AUTH_NET_LOGIN
    authozation_key = AUTH_NET_TXN_KEY
    number = card_number
    ActiveMerchant::Billing::Base.mode = Rails.env.to_sym

    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number => card_number,
      :month => card_expiry.month,
      :year => card_expiry.year,
      :first_name => bill_first_name,
      :last_name => bill_last_name,
      :type => card_type
    )    
  end
end
