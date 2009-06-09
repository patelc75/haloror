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
  module Medicationfill
  
      class Medicationfill < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<b>summary</b>: Name and clinical code for the medication.
#<b>remarks</b>: This name should be understandable to the person taking the medication, such as the brand name.
#<b>preferred-vocabulary</b>: Rxnorm
#<b>preferred-vocabulary</b>: NDC
#<em>value</em> is a HealthVault::WCData::Thing::Types::Codablevalue
        def name=(value)
          @children['name'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Codablevalue
        def name
          return @children['name'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Date the prescription was filled.
#<em>value</em> is a HealthVault::WCData::Dates::Approxdatetime
        def date_filled=(value)
          @children['date-filled'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Approxdatetime
        def date_filled
          return @children['date-filled'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Number of days supply of medication.
#<em>value</em> is a String
        def days_supply=(value)
          @children['days-supply'][:value] = value
        end
        
        #<b>returns</b>: a String
        def days_supply
          return @children['days-supply'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The date on which a prescription can be refilled.
#<em>value</em> is a HealthVault::WCData::Dates::Date
        def next_refill_date=(value)
          @children['next-refill-date'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Dates::Date
        def next_refill_date
          return @children['next-refill-date'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Number of medication refills left.
#<em>value</em> is a String
        def refills_left=(value)
          @children['refills-left'][:value] = value
        end
        
        #<b>returns</b>: a String
        def refills_left
          return @children['refills-left'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Pharmacy.
#<em>value</em> is a HealthVault::WCData::Thing::Types::Organization
        def pharmacy=(value)
          @children['pharmacy'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Thing::Types::Organization
        def pharmacy
          return @children['pharmacy'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Free form prescription number.
#<em>value</em> is a String
        def prescription_number=(value)
          @children['prescription-number'][:value] = value
        end
        
        #<b>returns</b>: a String
        def prescription_number
          return @children['prescription-number'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The lot number for the medication.
#<em>value</em> is a String
        def lot_number=(value)
          @children['lot-number'][:value] = value
        end
        
        #<b>returns</b>: a String
        def lot_number
          return @children['lot-number'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'medication-fill'
        
          
          @children['name'] = {:name => 'name', :class => HealthVault::WCData::Thing::Types::Codablevalue, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['name'][:value] = HealthVault::WCData::Thing::Types::Codablevalue.new
            
          
        
          
          @children['date-filled'] = {:name => 'date-filled', :class => HealthVault::WCData::Dates::Approxdatetime, :value => nil, :min => 0, :max => 1, :order => 2, :place => :element, :choice => 0 }
            
          
        
          
          @children['days-supply'] = {:name => 'days-supply', :class => String, :value => nil, :min => 0, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          
        
          
          @children['next-refill-date'] = {:name => 'next-refill-date', :class => HealthVault::WCData::Dates::Date, :value => nil, :min => 0, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          
        
          
          @children['refills-left'] = {:name => 'refills-left', :class => String, :value => nil, :min => 0, :max => 1, :order => 5, :place => :element, :choice => 0 }
            
          
        
          
          @children['pharmacy'] = {:name => 'pharmacy', :class => HealthVault::WCData::Thing::Types::Organization, :value => nil, :min => 0, :max => 1, :order => 6, :place => :element, :choice => 0 }
            
          
        
          
          @children['prescription-number'] = {:name => 'prescription-number', :class => String, :value => nil, :min => 0, :max => 1, :order => 7, :place => :element, :choice => 0 }
            
          
        
          
          @children['lot-number'] = {:name => 'lot-number', :class => String, :value => nil, :min => 0, :max => 1, :order => 8, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  end
  
  end
end
