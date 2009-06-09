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
module Types

      #Stringnz is a string
      class Stringnz < SimpleType
      
        
        #minLength = 1
        def minLength(value)
        
          return value.length > 1
        
        end
        
      
        
      
        def self.valid?(value)
          result = true
        
          
          result = result && self.minLength(value)
          
        
          
          
        
          return result
        end
      end
  end
  end
  
  end
end
