ActionController::Routing::Routes.draw do |map|

  map.order_group 'orders/select_group', :controller => 'orders', :action => 'select_group'
  map.order_group 'orders/switch_group', :controller => 'orders', :action => 'switch_group'
  
  # nested device resources
  # map.resources :device_types do |device_types|
  #   device_types.resources :device_models do |device_models|
  #     device_models.resources :device_revisions
  #     device_models.resources :rma_items
  #     device_models.resources :device_model_prices # prices based on coupon codes
  #   end
  # end    
  map.resources :access_modes  
  map.resources :carriers
  map.resources :shipping_options
  map.resources :device_model_prices, :collection => { :expired => :get, :usable => :get }
  map.resources :groups
  map.resources :installation_in_progress
  map.resources :time_zones

  map.resources :pools
  map.resources :gw_alarm_buttons
  map.resources :work_orders
  map.resources :atp_device
  map.resources :atp_next_device
  map.resources :self_test_results
  map.resources :dial_ups,:collection => {:dial_up_num => :get}
  map.resources :dial_up_statuses,:collection => {:last_successful => :get}
  map.resources :dial_up_alerts  
  map.resources :oscope_start_msgs
  map.resources :oscope_stop_msgs
  map.resources :oscope_msgs

  map.resources :bundle
  map.resources :alert_bundle
  map.resources :recurring_charges
  map.resources :subscriptions,:member => {:notes => :get}
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
  map.resources :users, :member => { :change_password => :get, :new_caregiver_options => :get, :triage => :get, :dismiss => :post, :toggle_test_mode => :post }, :collection => {:credentials => :get} do |user|
    user.resources :user_logs, :only => [:index, :show]
    user.resources :audits, :only => [:index, :show]
    user.resources :triage_audit_logs
  end
  map.resources :sessions,:member => {:edit_user_intake_form => :any,:user_intake_form_confirm => :get} # added automatically after running restful_authentication script
  map.resources :user_intakes, :collection => { :add_notes => :post, :index_fast => :get }
  map.resources :orders, :except => [:destroy, :edit, :update] do |order|
    order.resources :payment_gateway_responses, :only => [ :index, :show ]
  end
  map.resources :invoices, :except => [ :new, :destroy ] do |invoice|
    invoice.resources :audits, :only => [:index, :show]
    invoice.resources :invoice_notes, :as => :notes, :except => [:edit, :update]
  end
  map.resources :rmas, :has_many => :rma_items
  map.resources :purged_logs
  map.resources :triage_thresholds
  map.resources :triage_audit_logs, :except => [:destroy]
  
  #deprecated models
  #map.resources :caregivers, :active_scaffold => true 
  
  # this should be handled in root action below
  #    redirector controller should take care of Group search, not routes
  ActiveRecord::Base::Group.find(:all).each do |group|
	map.connect "/#{group.name}",:controller => 'users',:action => 'new'
	#map.connect "/#{group.name.downcase}",:controller => 'users',:action => 'new'
	#map.connect "/#{group.name.gsub('_','')}",:controller => 'users',:action => 'new'
  end
  
  
  map.connect '', :controller => 'redirector', :action => 'index'
  
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'init_user'
  map.activity '/dashboard', :controller => 'sandbox', :action => "dashboard"
  map.admin_signup '/admin/signup', :controller => 'user_admin', :action => 'new_admin'
  map.alert '/alert', :controller => 'alerts', :action => "alert"      
  map.dismiss_triage 'triage/:user_id/dismiss', :controller => 'triage_audit_logs', :action => 'new', :is_dismissed => true
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.management '/management', :controller => 'management', :action => 'issue' 
  map.new_caregiver_profile '/profiles/new_caregiver_profile/:user_id', :controller => 'profiles', :action => 'new_caregiver_profile'
  map.new_user_invoice '/invoices/new/:id', :controller => 'invoices', :action => 'new'
  map.registration '/registration', :controller => 'users', :action => 'registration'
  #map.reporting '/reporting/users', :controller => 'reporting', :action => 'users'
  map.resend '/installs/resend/:id',:controller => 'installs',:action => 'resend'
  map.signup '/signup/:group', :controller => 'users', :action => 'new'
  map.store '/order/:coupon_code', :controller => 'orders', :action => 'new', :coupon_code => '', :method => :get
  map.support '/support',:controller => 'util',:action => 'support'
  map.privacy_terms '/privacy', :controller => 'util', :action => 'privacy'
  map.terms '/terms', :controller => 'util', :action => 'terms'
  map.triage '/triage', :controller => 'users', :action => 'triage'
  map.undismiss_triage '/triage/:user_id/undismiss', :controller => 'triage_audit_logs', :action => 'new', :is_dismissed => false
  #map.users_in_group '/reporting/users/:group_name', :controller => 'reporting', :action => 'users'
  map.user_intake_form '/user/user_intake_form',:controller => 'users',:action => 'user_intake_form'
  map.user_intake_post '/user/user_intake_form',:controller => 'users',:action => 'user_intake_form', :method => :post
  
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
  map.connect ':controller/:action.:format'
  
end
