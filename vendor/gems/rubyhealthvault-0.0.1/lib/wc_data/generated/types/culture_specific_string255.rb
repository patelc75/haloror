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
  
      class CultureSpecificString255 < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a HealthVault::WCData::Types::String255
        def data=(value)
          @children['data'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Types::String255
        def data
          return @children['data'][:value]
        end
       
  
			 
      
        def initialize
          super
          self.tag_name = 'culturespecificstring255'
        
          
          @children['data'] = {:name => 'data', :class => HealthVault::WCData::Types::String255, :value => nil, :min => 1, :max => 1, :order => 0, :place => :extension, :choice => 0 }
            
          @children['data'][:value] = HealthVault::WCData::Types::String255.new
            
          
        
          
          @children[''] = {:name => '', :class => String, :value => nil, :min => 0, :max => 1, :order => 0, :place => :attribute, :choice => 0 }
            
          
        
        end
      end
  end
  
  end
end