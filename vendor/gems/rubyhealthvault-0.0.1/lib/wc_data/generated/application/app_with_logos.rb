# -*- ruby -*-
#--
# Copyright 2008 Danny Coates, Ashkan Farhadtouski
# All rights reserved.
# See LICENSE for permissions.
#++
# AUTOGENERATED ComplexType

module HealthVault
  module WCData
  module Application
  
      class AppWithLogos < ComplexType
        
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a HealthVault::WCData::Types::Guid
        def id=(value)
          @children['id'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Types::Guid
        def id
          return @children['id'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Types::CultureSpecificString255
        def add_name(value)
          @children['name'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Types::CultureSpecificString255
        def remove_name(value)
            @children['name'][:value].delete(value)
        end
        
        #<b>REQUIRED</b>
        #<b>returns</b>: a HealthVault::WCData::Types::CultureSpecificString255 Array
        def name
          return @children['name'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a String
        def app_auth_required=(value)
          @children['app-auth-required'][:value] = value
        end
        
        #<b>returns</b>: a String
        def app_auth_required
          return @children['app-auth-required'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a String
        def is_published=(value)
          @children['is-published'][:value] = value
        end
        
        #<b>returns</b>: a String
        def is_published
          return @children['is-published'][:value]
        end
       
  
			 
			 
       
        
        #<em>value</em> is a String
        def action_url=(value)
          @children['action-url'][:value] = value
        end
        
        #<b>returns</b>: a String
        def action_url
          return @children['action-url'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Types::CultureSpecificString
        def add_description(value)
          @children['description'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Types::CultureSpecificString
        def remove_description(value)
            @children['description'][:value].delete(value)
        end
        
        
        #<b>returns</b>: a HealthVault::WCData::Types::CultureSpecificString Array
        def description
          return @children['description'][:value]
        end
       
  
			 
			 
       
        #<em>value</em> is a HealthVault::WCData::Types::CultureSpecificString
        def add_auth_reason(value)
          @children['auth-reason'][:value] << value
        end
        
        #<em>value</em> is a #HealthVault::WCData::Types::CultureSpecificString
        def remove_auth_reason(value)
            @children['auth-reason'][:value].delete(value)
        end
        
        
        #<b>returns</b>: a HealthVault::WCData::Types::CultureSpecificString Array
        def auth_reason
          return @children['auth-reason'][:value]
        end
       
  
			 
			 
       
        
        #<b>remarks</b>: This parameter specifies the application's domain name. E-mail sent from the application, will have its From address originating from this domain. If the domain were myapp.com, then the From address will be "mailbox@myapp.com", where mailbox is specified in the send message request from the app.
#<em>value</em> is a HealthVault::WCData::Types::String255
        def domain_name=(value)
          @children['domain-name'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Types::String255
        def domain_name
          return @children['domain-name'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: Access token for client services.
#<b>remarks</b>: Token required to access HealthVault client services. For instance, the vocabulary search service.
#<em>value</em> is a HealthVault::WCData::Types::Guid
        def client_service_token=(value)
          @children['client-service-token'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Types::Guid
        def client_service_token
          return @children['client-service-token'][:value]
        end
       
  
			 
			 
       
        
        #<em>value</em> is a HealthVault::WCData::Application::AppLargeLogoInfo
        def large_logo=(value)
          @children['large-logo'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::AppLargeLogoInfo
        def large_logo
          return @children['large-logo'][:value]
        end
       
  
			 
			 
       
        
        #<em>value</em> is a HealthVault::WCData::Application::AppSmallLogoInfo
        def small_logo=(value)
          @children['small-logo'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::AppSmallLogoInfo
        def small_logo
          return @children['small-logo'][:value]
        end
       
  
			 
			 
       
        
        #<em>value</em> is a HealthVault::WCData::Application::AppPersistentTokens
        def persistent_tokens=(value)
          @children['persistent-tokens'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::AppPersistentTokens
        def persistent_tokens
          return @children['persistent-tokens'][:value]
        end
       
  
			 
			 
       
        #<b>REQUIRED</b>
        #<em>value</em> is a HealthVault::WCData::Auth::AuthXml
        def person_online_base_auth_xml=(value)
          @children['person-online-base-auth-xml'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Auth::AuthXml
        def person_online_base_auth_xml
          return @children['person-online-base-auth-xml'][:value]
        end
       
  
			 
			 
       
        
        #<em>value</em> is a HealthVault::WCData::Auth::AuthXml
        def person_offline_base_auth_xml=(value)
          @children['person-offline-base-auth-xml'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Auth::AuthXml
        def person_offline_base_auth_xml
          return @children['person-offline-base-auth-xml'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The application's privacy statement as a base64 encoded string and its corresponding content type.
#<em>value</em> is a HealthVault::WCData::Application::StatementInfo
        def privacy_statement=(value)
          @children['privacy-statement'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::StatementInfo
        def privacy_statement
          return @children['privacy-statement'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The application's terms of use statement as a base64 encoded string and its corresponding content type.
#<em>value</em> is a HealthVault::WCData::Application::StatementInfo
        def terms_of_use=(value)
          @children['terms-of-use'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::StatementInfo
        def terms_of_use
          return @children['terms-of-use'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The message to display to the use when direct to clinial authorization completes successfully.
#<b>remarks</b>: Represented as a base64 encoded string and its corresponding content type.
#<em>value</em> is a HealthVault::WCData::Application::StatementInfo
        def dtc_success_message=(value)
          @children['dtc-success-message'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::StatementInfo
        def dtc_success_message
          return @children['dtc-success-message'][:value]
        end
       
  
			 
			 
       
        
        #<b>summary</b>: The application attributes.
#<em>value</em> is a HealthVault::WCData::Application::ApplicationAttributes
        def app_attributes=(value)
          @children['app-attributes'][:value] = value
        end
        
        #<b>returns</b>: a HealthVault::WCData::Application::ApplicationAttributes
        def app_attributes
          return @children['app-attributes'][:value]
        end
       
  
      
        def initialize
          super
          self.tag_name = 'appwithlogos'
        
          
          @children['id'] = {:name => 'id', :class => HealthVault::WCData::Types::Guid, :value => nil, :min => 1, :max => 1, :order => 1, :place => :element, :choice => 0 }
            
          @children['id'][:value] = HealthVault::WCData::Types::Guid.new
            
          
        
          
          @children['name'] = {:name => 'name', :class => HealthVault::WCData::Types::CultureSpecificString255, :value => Array.new, :min => 1, :max => 999999, :order => 2, :place => :element, :choice => 0 }
          
        
          
          @children['app-auth-required'] = {:name => 'app-auth-required', :class => String, :value => nil, :min => 1, :max => 1, :order => 3, :place => :element, :choice => 0 }
            
          @children['app-auth-required'][:value] = String.new
            
          
        
          
          @children['is-published'] = {:name => 'is-published', :class => String, :value => nil, :min => 1, :max => 1, :order => 4, :place => :element, :choice => 0 }
            
          @children['is-published'][:value] = String.new
            
          
        
          
          @children['action-url'] = {:name => 'action-url', :class => String, :value => nil, :min => 0, :max => 1, :order => 5, :place => :element, :choice => 0 }
            
          
        
          
          @children['description'] = {:name => 'description', :class => HealthVault::WCData::Types::CultureSpecificString, :value => Array.new, :min => 0, :max => 999999, :order => 6, :place => :element, :choice => 0 }
          
        
          
          @children['auth-reason'] = {:name => 'auth-reason', :class => HealthVault::WCData::Types::CultureSpecificString, :value => Array.new, :min => 0, :max => 999999, :order => 7, :place => :element, :choice => 0 }
          
        
          
          @children['domain-name'] = {:name => 'domain-name', :class => HealthVault::WCData::Types::String255, :value => nil, :min => 0, :max => 1, :order => 8, :place => :element, :choice => 0 }
            
          
        
          
          @children['client-service-token'] = {:name => 'client-service-token', :class => HealthVault::WCData::Types::Guid, :value => nil, :min => 0, :max => 1, :order => 9, :place => :element, :choice => 0 }
            
          
        
          
          @children['large-logo'] = {:name => 'large-logo', :class => HealthVault::WCData::Application::AppLargeLogoInfo, :value => nil, :min => 0, :max => 1, :order => 10, :place => :element, :choice => 0 }
            
          
        
          
          @children['small-logo'] = {:name => 'small-logo', :class => HealthVault::WCData::Application::AppSmallLogoInfo, :value => nil, :min => 0, :max => 1, :order => 11, :place => :element, :choice => 0 }
            
          
        
          
          @children['persistent-tokens'] = {:name => 'persistent-tokens', :class => HealthVault::WCData::Application::AppPersistentTokens, :value => nil, :min => 0, :max => 1, :order => 12, :place => :element, :choice => 0 }
            
          
        
          
          @children['person-online-base-auth-xml'] = {:name => 'person-online-base-auth-xml', :class => HealthVault::WCData::Auth::AuthXml, :value => nil, :min => 1, :max => 1, :order => 13, :place => :element, :choice => 0 }
            
          @children['person-online-base-auth-xml'][:value] = HealthVault::WCData::Auth::AuthXml.new
            
          
        
          
          @children['person-offline-base-auth-xml'] = {:name => 'person-offline-base-auth-xml', :class => HealthVault::WCData::Auth::AuthXml, :value => nil, :min => 0, :max => 1, :order => 14, :place => :element, :choice => 0 }
            
          
        
          
          @children['privacy-statement'] = {:name => 'privacy-statement', :class => HealthVault::WCData::Application::StatementInfo, :value => nil, :min => 0, :max => 1, :order => 15, :place => :element, :choice => 0 }
            
          
        
          
          @children['terms-of-use'] = {:name => 'terms-of-use', :class => HealthVault::WCData::Application::StatementInfo, :value => nil, :min => 0, :max => 1, :order => 16, :place => :element, :choice => 0 }
            
          
        
          
          @children['dtc-success-message'] = {:name => 'dtc-success-message', :class => HealthVault::WCData::Application::StatementInfo, :value => nil, :min => 0, :max => 1, :order => 17, :place => :element, :choice => 0 }
            
          
        
          
          @children['app-attributes'] = {:name => 'app-attributes', :class => HealthVault::WCData::Application::ApplicationAttributes, :value => nil, :min => 0, :max => 1, :order => 18, :place => :element, :choice => 0 }
            
          
        
        end
      end
  end
  
  end
end
