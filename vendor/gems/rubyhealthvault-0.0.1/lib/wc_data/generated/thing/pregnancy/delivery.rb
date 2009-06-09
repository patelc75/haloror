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
  module Pregnancy
  
      class Delivery < ComplexType
        
  
			 
			 
       
        
        #<b>summary</b>: The place where the delivery occurred.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Organization
        def location=(value)
          @children['location'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Organization
        def location
          return @children['location'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The data and time of the delivery.
#<em>value</em> is a HealthVault::WCData::Dates::Approxdatetime
        def time_of_delivery=(value)
          @children['time-of-delivery'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Approxdatetime
        def time_of_delivery
          return @children['time-of-delivery'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The duration of the labor in minutes.
#<em>value</em> is a HealthVault::WCData::Thing::Types::PositiveDouble
        def labor_duration=(value)
          @children['labor-duration'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::PositiveDouble
        def labor_duration
          return @children['labor-duration'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def add_complications(value)
          @children['complications'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Thing::Types::Codablevalue
        def remove_complications(value)
            @children['complications'][:value].delete(value)
        end
        
        
        #<b>summary</b>: Any complications during labor and delivery.
#<b>preferred-vocabulary</b>: delivery-complications
#<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue Array
        def complications
          return @children['complications'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def add_anesthesia(value)
          @children['anesthesia'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Thing::Types::Codablevalue
        def remove_anesthesia(value)
            @children['anesthesia'][:value].delete(value)
        end
        
        
        #<b>summary</b>: The anesthesia used during labor and delivery.
#<b>preferred-vocabulary</b>: anesthesia-methods
#<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue Array
        def anesthesia
          return @children['anesthesia'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The method of the delivery.
#<b>preferred-vocabulary</b>: delivery-methods
#<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def delivery_method=(value)
          @children['delivery-method'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue
        def delivery_method
          return @children['delivery-method'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The outcome for a fetus.
#<b>preferred-vocabulary</b>: pregnancy-outcomes
#<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def outcome=(value)
          @children['outcome'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue
        def outcome
          return @children['outcome'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Details about the baby.
#<em>value</em> is a HealthVault::WCData::Thing::Pregnancy::Baby
        def baby=(value)
          @children['baby'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Pregnancy::Baby
        def baby
          return @children['baby'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Additional information about the delivery.
#<em>value</em> is a String
        def note=(value)
          @children['note'][:value] = value
        end
        
        #<b>returns</b>: a String
        def note
          return @children['note'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'delivery'
        
          
          @children['location'] = {:name => 'location', :class => HealthVault::WCData::Thing::Types::Organization, :value => nil, :min => 0, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          
        
          
          @children['time-of-delivery'] = {:name => 'time-of-delivery', :class => HealthVault::WCData::Dates::Approxdatetime, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
          
          @children['labor-duration'] = {:name => 'labor-duration', :class => HealthVault::WCData::Thing::Types::PositiveDouble, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
          
          @children['complications'] = {:name => 'complications', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => Array.new, :min => 0, :max => 999999, :order => 4, :place => :element, :choice => 0 }
          
        
          
          @children['anesthesia'] = {:name => 'anesthesia', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => Array.new, :min => 0, :max => 999999, :order => 5, :place => :element, :choice => 0 }
          
        
          
          @children['delivery-method'] = {:name => 'delivery-method', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => nil, :min => 0, :max => 1, :order => 6, :place => :element, :choice => 0 }
            
          
        
          
          @children['outcome'] = {:name => 'outcome', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => nil, :min => 0, :max => 1, :order => 7, :place => :element, :choice => 0 }
            
          
        
          
          @children['baby'] = {:name => 'baby', :class => HealthVault::WCData::Thing::Pregnancy::Baby, :value => nil, :min => 0, :max => 1, :order => 8, :place => :element, :choice => 0 }
            
          
        
          
          @children['note'] = {:name => 'note', :class => String, :value => nil, :min => 0, :max => 1, :order => 9, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
