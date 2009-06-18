# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++
# AUTOGENERATED ComplexType

module HealthVault
  module WCData
  module Thing
  module Types
  
      class Doublerange < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The minimum value for the range.
#<em>value</em> is a String
        def minimum_range=(value)
          @children['minimum-range'][:value] = value
        end
        
        #<b>returns</b>: a String
        def minimum_range
          return @children['minimum-range'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The maximum value for the range.
#<em>value</em> is a String
        def maximum_range=(value)
          @children['maximum-range'][:value] = value
        end
        
        #<b>returns</b>: a String
        def maximum_range
          return @children['maximum-range'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'double-range'
        
          
          @children['minimum-range'] = {:name => 'minimum-range', :class => String, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['minimum-range'][:value] = String.new
            
          
        
          
          @children['maximum-range'] = {:name => 'maximum-range', :class => String, :value => nil, :min => 1, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          @children['maximum-range'][:value] = String.new
            
          
        
        end
      end
  end
  end
  
  end
end