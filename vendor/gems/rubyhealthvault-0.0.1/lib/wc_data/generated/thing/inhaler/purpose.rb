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
module Inhaler

      #Purpose is a string
      class Purpose < SimpleType
      
        
            
        def self.control
          return 'Control'
        end
            
        def self.rescue
          return 'Rescue'
        end
            
        def self.combination
          return 'Combination'
        end
            
        def self.enum
          return ['Control','Rescue','Combination']
        end        
        
      
        
      
        def self.valid?(value)
          result = true
        
          
          result = result && self.enum.include?(value)
          
        
          
          
        
          return result
        end
      end
  end
  end
  
  end
end
