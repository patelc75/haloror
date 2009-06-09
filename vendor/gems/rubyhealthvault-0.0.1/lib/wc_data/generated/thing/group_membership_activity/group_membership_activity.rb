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
  module Groupmembershipactivity
  
      class Groupmembershipactivity < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The date and time of the activity.
#<em>value</em> is a HealthVault::WCData::Dates::Datetime
        def when=(value)
          @children['when'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Datetime
        def when
          return @children['when'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The activity that occurred.
#<b>remarks</b>: For example: RecordAuthorizedForApplication.
#<b>preferred-vocabulary</b>: group-membership-activities
#<em>value</em> is a HealthVault::WCData::Thing::Types::Codedvalue
        def activity=(value)
          @children['activity'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Codedvalue
        def activity
          return @children['activity'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Additional information for this activity.
#<em>value</em> is a String
        def activity_info=(value)
          @children['activity-info'][:value] = value
        end
        
        #<b>returns</b>: a String
        def activity_info
          return @children['activity-info'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'group-membership-activity'
        
          
          @children['when'] = {:name => 'when', :class => HealthVault::WCData::Dates::Datetime, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['when'][:value] = HealthVault::WCData::Dates::Datetime.new
            
          
        
          
          @children['activity'] = {:name => 'activity', :class => HealthVault::WCData::Thing::Types::Codedvalue, :value => nil, :min => 1, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          @children['activity'][:value] = HealthVault::WCData::Thing::Types::Codedvalue.new
            
          
        
          
          @children['activity-info'] = {:name => 'activity-info', :class => String, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
