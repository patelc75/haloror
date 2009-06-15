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
  module Sjam
  
      class Sleepam < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The date and time that the journal entry refers to.
#<em>value</em> is a HealthVault::WCData::Dates::Datetime
        def when=(value)
          @children['when'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Datetime
        def when
          return @children['when'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The time the person went to bed.
#<em>value</em> is a HealthVault::WCData::Dates::Time
        def bed_time=(value)
          @children['bed-time'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Time
        def bed_time
          return @children['bed-time'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The time the person woke up for a period of activity.
#<em>value</em> is a HealthVault::WCData::Dates::Time
        def wake_time=(value)
          @children['wake-time'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Time
        def wake_time
          return @children['wake-time'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The number of minutes slept.
#<em>value</em> is a String
        def sleep_minutes=(value)
          @children['sleep-minutes'][:value] = value
        end
        
        #<b>returns</b>: a String
        def sleep_minutes
          return @children['sleep-minutes'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The number of minutes it took to fall asleep.
#<em>value</em> is a String
        def settling_minutes=(value)
          @children['settling-minutes'][:value] = value
        end
        
        #<b>returns</b>: a String
        def settling_minutes
          return @children['settling-minutes'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Thing::Sjam::Awakening
        def add_awakening(value)
          @children['awakening'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Thing::Sjam::Awakening
        def remove_awakening(value)
            @children['awakening'][:value].delete(value)
        end
        
        
        #<b>summary</b>: The time and duration of each the person awoke during the night.
#<b>returns</b>: a HealthVault::WCData::Thing::Sjam::Awakening Array
        def awakening
          return @children['awakening'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: A description of the medications taken before going to bed.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def medications=(value)
          @children['medications'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue
        def medications
          return @children['medications'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a String
        def wake_state=(value)
          @children['wake-state'][:value] = value
        end
        
        #<b>returns</b>: a String
        def wake_state
          return @children['wake-state'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'sleep-am'
        
          
          @children['when'] = {:name => 'when', :class => HealthVault::WCData::Dates::Datetime, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['when'][:value] = HealthVault::WCData::Dates::Datetime.new
            
          
        
          
          @children['bed-time'] = {:name => 'bed-time', :class => HealthVault::WCData::Dates::Time, :value => nil, :min => 1, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          @children['bed-time'][:value] = HealthVault::WCData::Dates::Time.new
            
          
        
          
          @children['wake-time'] = {:name => 'wake-time', :class => HealthVault::WCData::Dates::Time, :value => nil, :min => 1, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          @children['wake-time'][:value] = HealthVault::WCData::Dates::Time.new
            
          
        
          
          @children['sleep-minutes'] = {:name => 'sleep-minutes', :class => String, :value => nil, :min => 1, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          @children['sleep-minutes'][:value] = String.new
            
          
        
          
          @children['settling-minutes'] = {:name => 'settling-minutes', :class => String, :value => nil, :min => 1, :max => 1, :order => 5, :place => :element, :choice => 0 }
            
          @children['settling-minutes'][:value] = String.new
            
          
        
          
          @children['awakening'] = {:name => 'awakening', :class => HealthVault::WCData::Thing::Sjam::Awakening, :value => Array.new, :min => 0, :max => 999999, :order => 6, :place => :element, :choice => 0 }
          
        
          
          @children['medications'] = {:name => 'medications', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => nil, :min => 0, :max => 1, :order => 7, :place => :element, :choice => 0 }
            
          
        
          
          @children['wake-state'] = {:name => 'wake-state', :class => String, :value => nil, :min => 1, :max => 1, :order => 8, :place => :element, :choice => 0 }
            
          @children['wake-state'][:value] = String.new
            
          
        
        end
      end
  end
  end
  
  end
end
