# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++
# AUTOGENERATED ComplexType

module HealthVault
  module WCData
  module Vocab
  
      class Vocabularysynonym < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a String
        def term=(value)
          @children['term'][:value] = value
        end
        
        #<b>returns</b>: a String
        def term
          return @children['term'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'vocabulary-synonym'
        
          
          @children['term'] = {:name => 'term', :class => String, :value => nil, :min => 1, :max => 1, :order => 0, :place => :attribute, :choice => 0 }
            
          @children['term'][:value] = String.new
            
          
        
        end
      end
  end
  
  end
end