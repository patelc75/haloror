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
  module Encounter
  
      class Encounter < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The date and time the medical encounter.
#<em>value</em> is a HealthVault::WCData::Dates::Datetime
        def when=(value)
          @children['when'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Datetime
        def when
          return @children['when'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The type of medical encounter.
#<em>value</em> is a String
        def type=(value)
          @children['type'][:value] = value
        end
        
        #<b>returns</b>: a String
        def type
          return @children['type'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The identify for the medical encounter.
#<em>value</em> is a String
        def id=(value)
          @children['id'][:value] = value
        end
        
        #<b>returns</b>: a String
        def id
          return @children['id'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The duration of the medical encounter.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Durationvalue
        def duration=(value)
          @children['duration'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Durationvalue
        def duration
          return @children['duration'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The location of the medical encounter .
#<em>value</em> is a HealthVault::WCData::Thing::Types::Address
        def location=(value)
          @children['location'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Address
        def location
          return @children['location'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Boolean consent for medical encounter.
#<em>value</em> is a String
        def consent_granted=(value)
          @children['consent-granted'][:value] = value
        end
        
        #<b>returns</b>: a String
        def consent_granted
          return @children['consent-granted'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'encounter'
        
          
          @children['when'] = {:name => 'when', :class => HealthVault::WCData::Dates::Datetime, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['when'][:value] = HealthVault::WCData::Dates::Datetime.new
            
          
        
          
          @children['type'] = {:name => 'type', :class => String, :value => nil, :min => 1, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          @children['type'][:value] = String.new
            
          
        
          
          @children['id'] = {:name => 'id', :class => String, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
          
          @children['duration'] = {:name => 'duration', :class => HealthVault::WCData::Thing::Types::Durationvalue, :value => nil, :min => 0, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          
        
          
          @children['location'] = {:name => 'location', :class => HealthVault::WCData::Thing::Types::Address, :value => nil, :min => 0, :max => 1, :order => 5, :place => :element, :choice => 0 }
            
          
        
          
          @children['consent-granted'] = {:name => 'consent-granted', :class => String, :value => nil, :min => 0, :max => 1, :order => 6, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
