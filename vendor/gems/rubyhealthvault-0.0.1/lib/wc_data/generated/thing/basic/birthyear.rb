# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++
# AUTOGENERATED class

module HealthVault
  module WCData
  module Thing
module Basic

      #Birthyear is a int
      class Birthyear < SimpleType
      
        
        #minInclusive = 1000
        def minInclusive(value)
        
          return value >= 1000
        
        end
        
      
        
        #maxInclusive = 3000
        def maxInclusive(value)
        
          return true
        
        end
        
      
        
      
        def self.valid?(value)
          result = true
        
          
          result = result && self.minInclusive(value)
          
        
          
          result = result && self.maxInclusive(value)
          
        
          
          
        
          return result
        end
      end
  end
  end
  
  end
end
