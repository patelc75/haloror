# we wanted the request parameters be captured within the response
#   this overrides the active_mercahnt authorize_net class to include REQUEST parameters in RESPONSE object
#   we can also override ActiveMerchant::PostsData.ssl_post but, we want request_parameters in response_object
#
module ActiveMerchant
  module Billing

    class AuthorizeNetGateway

      private

      def commit(action, money, parameters)
        parameters[:amount] = amount(money) unless action == 'VOID'

        # Only activate the test_request when the :test option is passed in
        parameters[:test_request] = @options[:test] ? 'TRUE' : 'FALSE'

        url = test? ? self.test_url : self.live_url
        #
        # ramonrails: extend to include request string in the response
        #
        # filter sensitive data: keep credit card and verification_code secure
        request_data = post_data(action, parameters.merge({:card_num => "filtered", :card_code => "filtered"}))
        data = ssl_post url, post_data(action, parameters)

        response = parse(data)

        message = message_from(response)

        # Return the response. The authorization can be taken out of the transaction_id
        # Test Mode on/off is something we have to parse from the response text.
        # It usually looks something like this
        #
        #   (TESTMODE) Successful Sale
        test_mode = test? || message =~ /TESTMODE/

        Response.new(success?(response), message, response, 
        :test => test_mode, 
        :authorization => response[:transaction_id],
        :fraud_review => fraud_review?(response),
        :avs_result => { :code => response[:avs_result_code] },
        :cvv_result => response[:card_code],
        :request_data => request_data, # added: ramonrails
        :request_headers => ''
        )
      end

      def recurring_commit(action, request)
        url = test? ? arb_test_url : arb_live_url
        #
        # ramonrails: extended this method to include request in response
        # filter sensitive data
        request_data = Hash.from_xml(request)
        request_data["ARBCreateSubscriptionRequest"]["subscription"]["payment"]["creditCard"]["cardNumber"] = "filtered"
        request_headers = {"Content-Type" => "text/xml"}
        
        xml = ssl_post(url, request, request_headers)

        response = recurring_parse(action, xml)

        message = response[:message] || response[:text]
        test_mode = test? || message =~ /Test Mode/
        success = response[:result_code] == 'Ok'

        Response.new(success, message, response,
        :test => test_mode,
        :authorization => response[:subscription_id],
        :request_data => request_data.to_xml, # ramonrails
        :request_headers => request_headers.to_yaml
        )
      end
    end
    
  end
end
