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
  module Labtestresults
  
      class Labtestresultvaluetype < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The value of the laboratory result.
#<b>preferred-vocabulary</b>: Contact the HealthVault team to help define this vocabulary.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Generalmeasurement
        def measurement=(value)
          @children['measurement'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Generalmeasurement
        def measurement
          return @children['measurement'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Thing::Labtestresults::Testresultrange
        def add_ranges(value)
          @children['ranges'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Thing::Labtestresults::Testresultrange
        def remove_ranges(value)
            @children['ranges'][:value].delete(value)
        end
        
        
        #<b>summary</b>: Ranges that are associated with this result.
#<b>remarks</b>: Each test result can contain multiple ranges that are useful to interpret the result value.
#<b>returns</b>: a HealthVault::WCData::Thing::Labtestresults::Testresultrange Array
        def ranges
          return @children['ranges'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def add_flag(value)
          @children['flag'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Thing::Types::Codablevalue
        def remove_flag(value)
            @children['flag'][:value].delete(value)
        end
        
        
        #<b>summary</b>: Flag for laboratory results.
#<b>remarks</b>: Example values are normal, critical, high and low.
#<b>preferred-vocabulary</b>: lab-results-flag
#<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue Array
        def flag
          return @children['flag'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'lab-test-result-value-type'
        
          
          @children['measurement'] = {:name => 'measurement', :class => HealthVault::WCData::Thing::Types::Generalmeasurement, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['measurement'][:value] = HealthVault::WCData::Thing::Types::Generalmeasurement.new
            
          
        
          
          @children['ranges'] = {:name => 'ranges', :class => HealthVault::WCData::Thing::Labtestresults::Testresultrange, :value => Array.new, :min => 0, :max => 999999, :order => 2, :place => :element, :choice => 0 }
          
        
          
          @children['flag'] = {:name => 'flag', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => Array.new, :min => 0, :max => 999999, :order => 3, :place => :element, :choice => 0 }
          
        
        end
      end
  end
  end
  
  end
end
