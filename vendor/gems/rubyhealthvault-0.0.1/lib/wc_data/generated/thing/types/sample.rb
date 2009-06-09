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
  
      class Sample < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: Offset is seconds from sample set base time.
#<em>value</em> is a HealthVault::WCData::Thing::Types::NonNegativeDouble
        def time_offset=(value)
          @children['time-offset'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::NonNegativeDouble
        def time_offset
          return @children['time-offset'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Description of sample.
#<em>value</em> is a String
        def note=(value)
          @children['note'][:value] = value
        end
        
        #<b>returns</b>: a String
        def note
          return @children['note'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Value of sample.
#<b>remarks</b>: The value of the sample can be any string. The value depends on the type of sample. Some sample types will have a simple int or double as the value. Others will have a comma separated list. For example, a "position" sample may have "25E,66N" (longitude,latitude) as the value.
#<em>value</em> is a String
        def value=(value)
          @children['value'][:value] = value
        end
        
        #<b>returns</b>: a String
        def value
          return @children['value'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'sample'
        
          
          @children['time-offset'] = {:name => 'time-offset', :class => HealthVault::WCData::Thing::Types::NonNegativeDouble, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['time-offset'][:value] = HealthVault::WCData::Thing::Types::NonNegativeDouble.new
            
          
        
          
          @children['note'] = {:name => 'note', :class => String, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
          
          @children['value'] = {:name => 'value', :class => String, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
