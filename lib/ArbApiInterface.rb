# Before working with this sample code, please be sure to read the accompanying Readme.txt file.
# It contains important information regarding the appropriate use of and conditions for this
# sample code. Also, please pay particular attention to the comments included in each individual
# code file, as they will assist you in the unique and correct implementation of this code on
# your specific platform.
#
# Copyright 2007 Authorize.Net Corp.


# This is a Ruby script to create an ARB subscription using the ARB API.
# To run it you need Ruby 1.8.4, Builder 2.0.0 (Just type "gem install builder" to install the
# XML builder once you have Ruby).

# To test the sample just type "arbapisample.rb" The program just parses the XML response and
# prints a subscription ID if the create is successful or it displays an error code and error
# message.


class MerchantAuthenticationType < Struct.new(:name, :transactionKey)
end

class NameAndAddressType < Struct.new(:firstName,:lastName,:company,:address,:city,:state,:zip,:country)
end

class IntervalType < Struct.new(:length,:unit)
end

class PaymentScheduleType < Struct.new(:interval,:startDate,:totalOccurrences,:trialOccurrences)
end

class CreditCardType < Struct.new(:cardNumber,:expirationDate,:cardCode)
end

class Payment < Struct.new(:creditcard)
end

class ARBSubscriptionType < Struct.new(:name, :paymentschedule, :amount, :trialamount, :payment, :billTo, :shipTo)
end

class ResponseMessage
attr_accessor :code, :text
end

class ApiResponse
attr_accessor :success, :messages
end

class CreateSubscriptionResponse < ApiResponse
attr_accessor :subscriptionid
end

class ErrorResponse < ApiResponse
end




