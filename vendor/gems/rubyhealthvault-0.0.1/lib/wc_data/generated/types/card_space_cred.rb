# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++
# AUTOGENERATED ComplexType

module HealthVault
  module WCData
  module Types
  
      class CardSpaceCred < ComplexType
        
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::ComplexType
        def add_anything(value)
          @children['anything'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::ComplexType
        def remove_anything(value)
            @children['anything'][:value].delete(value)
        end
        
        #<b>REQUIRED</b>
        #<b>summary</b>: The SAML token.
#<b>remarks</b>: The SAML token consists of raw XML that is embedded in the request.
#<b>returns</b>: a HealthVault::WCData::ComplexType Array
        def anything
          return @children['anything'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'cardspacecred'
        
          
          @children['anything'] = {:name => 'anything', :class => HealthVault::WCData::ComplexType, :value => Array.new, :min => 1, :max => 999999, :order => 1, :place => :extension, :choice => 0 }
          
        
        end
      end
  end
  
  end
end
