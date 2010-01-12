ActionController::Routing::Routes.draw do |map|
  map.resources :installation_in_progress
  map.resources :time_zones
  map.resources :access_modes
  map.resources :carriers

  map.resources :pools
  map.resources :gw_alarm_buttons
  map.resources :work_orders
  map.resources :atp_device
  map.resources :atp_next_device
  map.resources :self_test_results
  map.resources :dial_ups

  map.resources :vitals
  
  map.resources :oscope_start_msgs
  map.resources :oscope_stop_msgs
  map.resources :oscope_msgs

  map.resources :bundle
  map.resources :alert_bundle
  map.resources :recurring_charges
  map.resources :subscriptions
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
  map.resources :weight_scales
  map.resources :blood_pressures
  
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
  map.resources :users, :sessions,:member => {:edit_user_intake_form => :any}#added automatically after running restful_authentication script
  
  #deprecated models
  #map.resources :caregivers, :active_scaffold => true 
  
  ActiveRecord::Base::Group.find(:all).each do |group|
	map.connect "/#{group.name}",:controller => 'users',:action => 'new'
	#map.connect "/#{group.name.downcase}",:controller => 'users',:action => 'new'
	#map.connect "/#{group.name.gsub('_','')}",:controller => 'users',:action => 'new'
  end
  
  
  map.connect '', :controller => 'redirector', :action => 'index'
  
  map.signup '/signup/:group', :controller => 'users', :action => 'new'
  map.registration '/registration', :controller => 'users', :action => 'registration'
  map.admin_signup '/admin/signup', :controller => 'user_admin', :action => 'new_admin'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'init_user'
  map.connect '/reporting', :controller => 'reporting', :action => 'users'
  map.terms '/terms', :controller => 'util', :action => 'terms'
  map.terms '/privacy', :controller => 'util', :action => 'privacy'
  map.new_caregiver_profile '/profiles/new_caregiver_profile/:user_id', :controller => 'profiles', :action => 'new_caregiver_profile'
  map.resend '/installs/resend/:id',:controller => 'installs',:action => 'resend'
  map.support '/support',:controller => 'util',:action => 'support'
  map.user_intake_form '/user/user_intake_form',:controller => 'users',:action => 'user_intake_form'
  
  #map.resend '/resend/:id', :controller => 'installs', :action => 'resend'
    # 
    # map.signup_caregiver '/activate/caregiver/:activation_code', :controller => 'users', :action => 'init_caregiver'
  


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
