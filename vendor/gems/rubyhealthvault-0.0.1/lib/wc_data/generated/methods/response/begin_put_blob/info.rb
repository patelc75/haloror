# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++
# AUTOGENERATED ComplexType

module HealthVault
  module WCData
  module Methods
  module Response
  module BeginPutBlob
  
      class Info < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The authentication token to be supplied with a streaming put blob request.
#<b>remarks</b>: The token has a limited time-to-live. When the token expires, requests will fail with access denied.
#<em>value</em> is a HealthVault::WCData::Types::Stringnz
        def stream_auth_token=(value)
          @children['stream-auth-token'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Types::Stringnz
        def stream_auth_token
          return @children['stream-auth-token'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'info'
        
          
          @children['stream-auth-token'] = {:name => 'stream-auth-token', :class => HealthVault::WCData::Types::Stringnz, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['stream-auth-token'][:value] = HealthVault::WCData::Types::Stringnz.new
            
          
        
        end
      end
  end
  end
  end
  
  end
end