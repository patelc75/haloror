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
  module Lifegoal
  
      class Lifegoal < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: Free-form description of the goal.
#<em>value</em> is a String
        def description=(value)
          @children['description'][:value] = value
        end
        
        #<b>returns</b>: a String
        def description
          return @children['description'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: General information about the goal such as the start date, completion date, and current status.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Goal
        def goal_info=(value)
          @children['goal-info'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Goal
        def goal_info
          return @children['goal-info'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'life-goal'
        
          
          @children['description'] = {:name => 'description', :class => String, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['description'][:value] = String.new
            
          
        
          
          @children['goal-info'] = {:name => 'goal-info', :class => HealthVault::WCData::Thing::Types::Goal, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
