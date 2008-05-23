ActionController::Routing::Routes.draw do |map|


  #device alert models derived from RestfulAuthController
  map.resources :battery_pluggeds
  map.resources :battery_unpluggeds
  map.resources :battery_charge_completes
  map.resources :strap_fasteneds
  map.resources :battery_criticals
  map.resources :strap_removeds
  
  
  #mgmt protocol models derived from RestfulAuthController
  map.resources :mgmt_acks
  map.resources :mgmt_queries
  map.resources :mgmt_responses
  map.resources :mgmt_cmds
  
  #device data models derived from RestfulAuthController
  map.resources :vitals
  map.resources :steps
  map.resources :batteries
  map.resources :skin_temps
  
  #critical device data models derived from RestfulAuthController
  map.resources :falls
  map.resources :panics
  
  #other models derived from RestfulAuthController
  map.resources :halo_debug_msgs
  
  #misc models 
  map.resources :events  
  map.resources :call_orders
  map.resources :raw_data_files, :member => {:download => :get}
  
  #user related models
  map.resources :profiles
  map.resources :users, :sessions  #added automatically after running restful_authentication script
  
  #deprecated models
  #map.resources :caregivers, :active_scaffold => true 
  
  map.connect '', :controller => 'chart', :action => 'index'
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.connect '/reporting', :controller => 'reporting', :action => 'users'


  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
