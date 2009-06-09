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
  module Peakflow
  
      class Peakflow < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The date and time of the measurement.
#<em>value</em> is a HealthVault::WCData::Dates::Approxdatetime
        def when=(value)
          @children['when'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Approxdatetime
        def when
          return @children['when'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The peak expiratory flow, measured in liters/second.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Flowvalue
        def pef=(value)
          @children['pef'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Flowvalue
        def pef
          return @children['pef'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The forced expiratory volume in one second, measured in liters.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Volumevalue
        def fev1=(value)
          @children['fev1'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Volumevalue
        def fev1
          return @children['fev1'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The forced expiratory volume in six seconds, measured in liters.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Volumevalue
        def fev6=(value)
          @children['fev6'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Volumevalue
        def fev6
          return @children['fev6'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def add_measurement_flags(value)
          @children['measurement-flags'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Thing::Types::Codablevalue
        def remove_measurement_flags(value)
            @children['measurement-flags'][:value].delete(value)
        end
        
        
        #<b>summary</b>: Additional information about the measurement.
#<b>remarks</b>: Examples: Incomplete measurement.
#<b>preferred-vocabulary</b>: Contact the HealthVault team to help define this vocabulary.
#<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue Array
        def measurement_flags
          return @children['measurement-flags'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'peak-flow'
        
          
          @children['when'] = {:name => 'when', :class => HealthVault::WCData::Dates::Approxdatetime, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['when'][:value] = HealthVault::WCData::Dates::Approxdatetime.new
            
          
        
          
          @children['pef'] = {:name => 'pef', :class => HealthVault::WCData::Thing::Types::Flowvalue, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
          
          @children['fev1'] = {:name => 'fev1', :class => HealthVault::WCData::Thing::Types::Volumevalue, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
          
          @children['fev6'] = {:name => 'fev6', :class => HealthVault::WCData::Thing::Types::Volumevalue, :value => nil, :min => 0, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          
        
          
          @children['measurement-flags'] = {:name => 'measurement-flags', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => Array.new, :min => 0, :max => 999999, :order => 5, :place => :element, :choice => 0 }
          
        
        end
      end
  end
  end
  
  end
end
