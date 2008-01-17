ActionController::Routing::Routes.draw do |map|
  map.resources :orientations
  map.resources :steps
  map.resources :events  
  map.resources :batteries
  map.resources :skin_temps
  map.resources :falls
  map.resources :activities
  map.resources :panics
  map.resources :call_orders
  map.resources :raw_data_files, :member => {:download => :get}
  map.resources :heartrates
  map.resources :caregivers
  #map.resources :caregivers, :active_scaffold => true
 
  #added automatically after running restful_authentication script
  map.resources :users do |user|
    user.resource :profile
  end
  map.resources :sessions  
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'


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
