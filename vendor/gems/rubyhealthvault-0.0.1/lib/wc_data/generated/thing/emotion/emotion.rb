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
  module Emotion
  
      class Emotion < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The date and time when the emotional state occurred.
#<em>value</em> is a HealthVault::WCData::Dates::Datetime
        def when=(value)
          @children['when'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Datetime
        def when
          return @children['when'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: A subjective ranking of the emotional state.
#<b>remarks</b>: The value ranges from one to five, with one being sad and five being very happy.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Onetofive
        def mood=(value)
          @children['mood'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Onetofive
        def mood
          return @children['mood'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: A subjective ranking of the person's stress level.
#<b>remarks</b>: The value ranges from one to five, with one being relaxed to five being stressed.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Onetofive
        def stress=(value)
          @children['stress'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Onetofive
        def stress
          return @children['stress'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: A subjective ranking of the person's health.
#<b>remarks</b>: The value ranges from one to five, with one being sick to five being healthy.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Onetofive
        def wellbeing=(value)
          @children['wellbeing'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Onetofive
        def wellbeing
          return @children['wellbeing'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'emotion'
        
          
          @children['when'] = {:name => 'when', :class => HealthVault::WCData::Dates::Datetime, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['when'][:value] = HealthVault::WCData::Dates::Datetime.new
            
          
        
          
          @children['mood'] = {:name => 'mood', :class => HealthVault::WCData::Thing::Types::Onetofive, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
          
          @children['stress'] = {:name => 'stress', :class => HealthVault::WCData::Thing::Types::Onetofive, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
          
          @children['wellbeing'] = {:name => 'wellbeing', :class => HealthVault::WCData::Thing::Types::Onetofive, :value => nil, :min => 0, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
