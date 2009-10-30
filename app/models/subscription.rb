require "ArbApiLib"

class Subscription < ActiveRecord::Base
	
	belongs_to :senior, :class_name => "User", :foreign_key => "senior_user_id"
	belongs_to :subscriber, :class_name => "User", :foreign_key => "subscriber_user_id"

  def self.credit_card_validate(senior_user_id,subscriber_user_id,user,credit_card,flash)
    bill_to_fn = user.profile.first_name
		bill_to_ln = user.profile.last_name

    # Start authorize.net create subscription code
  	auth = MerchantAuthenticationType.new(AUTH_NET_LOGIN, AUTH_NET_TXN_KEY)

  	# subscription name - use subscriber user id
		subname = "sen_uid-#{senior_user_id}-sub_uid-#{subscriber_user_id}"

		RAILS_DEFAULT_LOGGER.info("Attempting to create Authorize.Net subscription.  Subscription name = #{subname}")
		RAILS_DEFAULT_LOGGER.debug("Authorize.Net AUTH_NET_LOGIN= #{AUTH_NET_LOGIN}, AUTH_NET_TXN_KEY= #{AUTH_NET_TXN_KEY}")

	  # 1 month interval
		interval = IntervalType.new(AUTH_NET_SUBSCRIPTION_INTERVAL, AUTH_NET_SUBSCRIPTION_INTERVAL_UNITS)

		sub_start_date = Time.now
		schedule = PaymentScheduleType.new(interval, sub_start_date.strftime("%Y-%m-%d"), AUTH_NET_SUBSCRIPTION_TOTAL_OCCURANCES, 0)

		RAILS_DEFAULT_LOGGER.info("Authorize.Net Subscription startdate = #{sub_start_date.strftime("%Y-%m-%d")} num_occurances = #{AUTH_NET_SUBSCRIPTION_TOTAL_OCCURANCES} interval = #{AUTH_NET_SUBSCRIPTION_INTERVAL} interval_units = #{AUTH_NET_SUBSCRIPTION_INTERVAL_UNITS}")

		cc_exp = "#{credit_card[:"expiration_time(1i)"]}-#{credit_card[:"expiration_time(2i)"]}"

		cinfo = CreditCardType.new(params[:credit_card][:number], cc_exp)

		binfo = NameAndAddressType.new(bill_to_fn, bill_to_ln)
		RAILS_DEFAULT_LOGGER.info("Authorize.Net Subscription cc fn = #{binfo.firstName} cc ln = #{binfo.lastName}")

	  @senior = User.find(senior_user_id)

		charge = @senior.group_recurring_charge

		aReq = ArbApi.new
		xmlout = aReq.CreateSubscription(auth,subname,schedule,charge,0, cinfo,binfo)

		RAILS_DEFAULT_LOGGER.info("Authorize.Net Subscription amount = #{AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL}")

		RAILS_DEFAULT_LOGGER.info("Authorize.Net Submitting to URL = #{AUTH_NET_URL}")
		xmlresp = HttpTransport.TransmitRequest(xmlout, AUTH_NET_URL)

		apiresp = aReq.ProcessResponse(xmlresp)

		RAILS_DEFAULT_LOGGER.info("\nXML Dump:" + xmlresp)

		if apiresp.success 
		  RAILS_DEFAULT_LOGGER.info("Subscription Created successfully")
		  RAILS_DEFAULT_LOGGER.info("Subscription id : " + apiresp.subscriptionid)
#=begin comment out if you want to test sign up without credit card failure throwing an exception
		else
			RAILS_DEFAULT_LOGGER.info("Subscription Creation Failed")
			apiresp.messages.each { |message| 
			  RAILS_DEFAULT_LOGGER.info("Error Code=" + message.code)
			  RAILS_DEFAULT_LOGGER.info("Error Message = " + message.text)
			  flash[:warning] = "Unable to create subscription.  Check credit card information. Error Code=" + message.code + ", Error Message = " + message.text
			}   
			raise "Unable to create subscription."
#=end
		end

		@subscription = Subscription.new
		@subscription[:arb_subscriptionId] = apiresp.subscriptionid
		@subscription[:senior_user_id] = senior_user_id
		@subscription[:subscriber_user_id] = subscriber_user_id
		@subscription[:cc_last_four] = credit_card[:number].last(4)
		@subscription[:special_notes] = credit_card[:special_notes]
		@subscription[:bill_amount] = charge
		@subscription[:bill_to_first_name] = bill_to_fn
		@subscription[:bill_to_last_name] = bill_to_ln
		@subscription[:bill_start_date] = sub_start_date
		@subscription.save!
  end
end
