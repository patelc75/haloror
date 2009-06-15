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
  module Dietaryintakedaily
  
      class Dietaryintakedaily < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: The date of consumption.
#<em>value</em> is a HealthVault::WCData::Dates::Date
        def when=(value)
          @children['when'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Date
        def when
          return @children['when'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of calories consumed in the day.
#<b>remarks</b>: Calories are measured in kilocalories (kCal).
#<em>value</em> is a String
        def calories=(value)
          @children['calories'][:value] = value
        end
        
        #<b>returns</b>: a String
        def calories
          return @children['calories'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The total amount of fat consumed in the day.
#<b>remarks</b>: Fat is usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def total_fat=(value)
          @children['total-fat'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def total_fat
          return @children['total-fat'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The total amount of saturated fat consumed in the day.
#<b>remarks</b>: Fat is usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def saturated_fat=(value)
          @children['saturated-fat'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def saturated_fat
          return @children['saturated-fat'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The total amount of trans fat consumed in the day.
#<b>remarks</b>: Fat is usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def trans_fat=(value)
          @children['trans-fat'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def trans_fat
          return @children['trans-fat'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of protein consumed in the day.
#<b>remarks</b>: Protein is usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def protein=(value)
          @children['protein'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def protein
          return @children['protein'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of carbohydrates consumed in the day.
#<b>remarks</b>: Carbohydrates are usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def total_carbohydrates=(value)
          @children['total-carbohydrates'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def total_carbohydrates
          return @children['total-carbohydrates'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of dietary fiber consumed in the day.
#<b>remarks</b>: Dietary fiber is usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def dietary_fiber=(value)
          @children['dietary-fiber'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def dietary_fiber
          return @children['dietary-fiber'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of sugars consumed in the day.
#<b>remarks</b>: Sugar is usually measured in grams (g).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def sugars=(value)
          @children['sugars'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def sugars
          return @children['sugars'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of sodiam consumed in the day.
#<b>remarks</b>: Sodium is usually measured in milligrams (mg).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def sodium=(value)
          @children['sodium'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def sodium
          return @children['sodium'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The amount of cholesterol consumed in the day.
#<b>remarks</b>: Cholesterol is usually measured in milligrams (mg).
#<em>value</em> is a HealthVault::WCData::Thing::Types::Weightvalue
        def cholesterol=(value)
          @children['cholesterol'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Weightvalue
        def cholesterol
          return @children['cholesterol'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'dietary-intake-daily'
        
          
          @children['when'] = {:name => 'when', :class => HealthVault::WCData::Dates::Date, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['when'][:value] = HealthVault::WCData::Dates::Date.new
            
          
        
          
          @children['calories'] = {:name => 'calories', :class => String, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
          
          @children['total-fat'] = {:name => 'total-fat', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
          
          @children['saturated-fat'] = {:name => 'saturated-fat', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          
        
          
          @children['trans-fat'] = {:name => 'trans-fat', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 5, :place => :element, :choice => 0 }
            
          
        
          
          @children['protein'] = {:name => 'protein', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 6, :place => :element, :choice => 0 }
            
          
        
          
          @children['total-carbohydrates'] = {:name => 'total-carbohydrates', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 7, :place => :element, :choice => 0 }
            
          
        
          
          @children['dietary-fiber'] = {:name => 'dietary-fiber', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 8, :place => :element, :choice => 0 }
            
          
        
          
          @children['sugars'] = {:name => 'sugars', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 9, :place => :element, :choice => 0 }
            
          
        
          
          @children['sodium'] = {:name => 'sodium', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 10, :place => :element, :choice => 0 }
            
          
        
          
          @children['cholesterol'] = {:name => 'cholesterol', :class => HealthVault::WCData::Thing::Types::Weightvalue, :value => nil, :min => 0, :max => 1, :order => 11, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
