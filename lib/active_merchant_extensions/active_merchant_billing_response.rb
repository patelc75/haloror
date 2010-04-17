# we wanted the request parameters be captured within the response
#   this overrides the active_mercahnt authorize_net class to include REQUEST parameters in RESPONSE object
#   we can also override ActiveMerchant::PostsData.ssl_post but, we want request_parameters in response_object
#
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    
    class Response
      attr_accessor :request_data, :request_headers
      
      def initialize(success, message, params = {}, options = {})
        @success, @message, @params = success, message, params.stringify_keys
        @test = options[:test] || false        
        @authorization = options[:authorization]
        @fraud_review = options[:fraud_review]
        @avs_result = AVSResult.new(options[:avs_result]).to_hash
        @cvv_result = CVVResult.new(options[:cvv_result]).to_hash
        @request_data = options[:request_data] # ramonrails: extend these 2 attributes
        @request_headers = options[:request_headers]
      end
    end
    
  end
end
