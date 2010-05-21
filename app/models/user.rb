require 'digest/sha1'
class User < ActiveRecord::Base
  #composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  
  # arranged associations alphabetically for easier traversing
  
  acts_as_authorized_user
  acts_as_authorizable
  acts_as_audited :except => [:is_caregiver, :is_new_caregiver]
  
  belongs_to :creator, :class_name => 'User',:foreign_key => 'created_by'
  
  has_one  :profile, :dependent => :destroy
  has_many :access_logs
  has_many :batteries
  has_many :blood_pressure
  has_many :dial_ups
  has_many :event_actions
  has_many :events
  has_many :falls  
  has_many :halo_debug_msgs
  has_many :mgmt_cmds
  has_many :notes
  has_many :orders_created, :class_name => 'Order', :foreign_key => 'created_by'
  has_many :orders_updated, :class_name => 'Order', :foreign_key => 'updated_by'
  has_many :panics
  has_many :rma_items
  has_many :roles_users,:dependent => :destroy
  has_many :roles, :through => :roles_users#, :include => [:roles_users]
  # has_and_belongs_to_many :roles
  has_many :self_test_sessions
  has_many :skin_temps
  has_many :steps
  has_many :subscriptions, :foreign_key => "senior_user_id"
  has_many :vitals
  has_many :weight_scales
  has_many :purged_logs
  #belongs_to :role
  #has_one :roles_user
  #has_one :roles_users_option
  
  has_and_belongs_to_many :devices
  has_and_belongs_to_many :user_intakes # replaced with has_many :through on Senior, Subscriber, Caregiver
  attr_accessor :is_keyholder, :phone_active, :email_active, :text_active, :active, :need_validation, :lazy_roles
  
  #has_many :call_orders, :order => :position
  #has_many :caregivers, :through => :call_orders #self referential many to many
  
  # Virtual attribute for the unencrypted password
  cattr_accessor :current_user #stored in memory instead of table
  attr_accessor :password
  attr_accessor :current_password,:username_confirmation
  validates_presence_of     :login, :if => :password_required?
  #validates_presence_of     :email
  #validates_presence_of     :serial_number
  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  
  validates_length_of       :login,    :within => 3..40, :if => :password_required?
  validates_length_of       :email,    :within => 3..100, :unless => :skip_validation
  validates_format_of       :email,    
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                            :message => 'must be valid', :if => :need_validation
  #validates_length_of       :serial_number, :is => 10
  
  validates_uniqueness_of   :login, :case_sensitive => false, :if => :login_not_blank?
  
  # validate associations
  # validates_associated :profile, :unless => "skip_validation" # Proc.new {|e| skip_validation }
  
  before_save :encrypt_password
  before_create :make_activation_code
  # after_save :post_process  
  
  def after_initialize
    self.need_validation = true
    # example:
    #   user.roles = {:halouser => @group}
    #   user.roles[:subscriber] = @senior
    self.lazy_roles = {} # lazy loading roles of this user
  end

  def skip_validation
    !need_validation
  end
  
  def validate
  	if self.username_confirmation
  		if self.username_confirmation != self.login
  			self.errors.add("user confirmation","does not match with username.")
  		end
  	end
  end
  
  def skip_validation=(value = false)
    self.need_validation = !value
    skip_associations_validation
  end
    
  # build associated model
  def build_associations
    # self.build_profile
    self.profile = (Profile.find_by_user_id(self.id) || Profile.new(:user_id => self.id)) if profile.blank?
  end
  
  # assign nil to the associated model if the record is just new with no data assigned
  def collapse_associations
    (self.profile = nil if profile.nothing_assigned?) unless profile.blank?
  end
  
  # def post_process
  #   profile.save if !profile.blank? && profile.new_record?
  # end

  # checks if any attribute was assigned a value after "new"
  # helps in user intake at least
  # examples:
  #    Profile.new.nothing_assigned? => true
  #    Profile.new(:first_name => "first name").nothing_assigned? => false
  def nothing_assigned?
    attributes.values.compact.blank?
  end

  # profile_attributes hash can be given here to create a related profile
  #
  def profile_attributes=(attributes)
    if profile.blank?
      # any_existing_profile = Profile.find_by_user_id(self.id)
      # if any_existing_profile
      #   self.profile = any_existing_profile
      #   self.profile.attributes = attributes
      # else
        self.build_profile(attributes) # .merge("user_id" => self)
      # end
    else
      # keep the existing user connected. no need to re-assign
      self.profile.attributes = attributes # .reject {|k,v| k == "user_id"} # except user_id, take all attributes
    end
  end
  
  # # OBSOLETE for now. role options are handled at user_intake
  # # roles_users_option attributes
  # def role_attributes=(attributes)
  #   # create roles_users_option records here
  #   # debugger
  # end

  # TODO: why do we need this?
  # def before_validation
  #   self.email = "no-email@halomonitoring.com" if self.email == ''
  # end
  
  # fetch position if "this" user assuming he/she is a caregiver to given senior
  def caregiver_position_for(senior)
    options_attribute_for_senior(senior, :position)
  end
  
  # get attribute value from the roles_users_options this user has for senior
  # return blank when not found
  def options_attribute_for_senior(senior, attribute)
    options = options_for_senior(senior)
    options.blank? ? nil : options.send("#{attribute}".to_sym)
  end
  
  # methods for a RESTful approach
  # using the authorization plugin for the following methods
  # examples:
  #   is_halouser?, is_subscriber?, is_caregiver?
  #   is_subscriber_for? senior_user_object
  #   is_caregiver_to? senior_user_object
  #   is_caregiver_to_what => get array if users I am caregiving
  #   has_caregiver => get array of caregivers for me
  def options_for_senior(the_senior, attributes = nil)
    if attributes.nil?
      if self.is_caregiver_of?( the_senior)
        role = self.roles.first(:conditions => {
          :name => "caregiver", :authorizable_id => the_senior, :authorizable_type => "User"
        })
        options = options_for_role(role) unless role.blank?
      end
    else
      self.is_caregiver_of(the_senior)
      role = self.roles.first(:conditions => {
        :name => "caregiver", :authorizable_id => the_senior, :authorizable_type => "User"
      })
      options = self.options_for_role(role, attributes)
    end
    options
  end
  
  def options_for_role(role, attributes = nil)
    role_id = (role.is_a?(Role) ? role.id : role)
    if attributes.blank?
      role_user = RolesUser.find_by_user_id_and_role_id(self.id, role_id)
      role_user.blank? ? nil : role_user.roles_users_option
    else
      role_user = RolesUser.find_or_create_by_user_id_and_role_id(self.id, role_id) # find | create
      role_user.create_roles_users_option(attributes)
    end
  end

  def dispatch_emails
    if self.is_halouser? && !email.blank? # WARNING: DEPRECATED user[:is_new_halouser] == true
      UserMailer.deliver_signup_installation(self, self)
    else
      UserMailer.deliver_signup_notification(self) unless self.is_caregiver? || self.is_subscriber? # (user[:is_caregiver] or user[:is_new_subscriber])
    end
    #
    # activation email gets delivered anyways
    UserMailer.deliver_activation(self) if recently_activated?
  end
  
  # ramonrails: above this are methods to help self contained logic for user_intake
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :password, :password_confirmation
  
  def username
    return self.name rescue ""
  end
  
  def owner_user # for auditing
    self
  rescue
    nil
  end

  def battery_status
    if @battery = Battery.find(:first,:conditions => ["user_id = ? and acpower_status is not null",self.id],:order => 'timestamp desc')
      return @battery.acpower_status == true ? 'Battery Plugged' : 'Battery Unplugged'
    else
      battery_plugged = BatteryPlugged.find(:first,:conditions => ["user_id = ?",self.id],:order => 'timestamp desc')
      battery_unplugged = BatteryUnplugged.find(:first,:conditions => ["user_id = ?",self.id],:order => 'timestamp desc')
      if battery_plugged and battery_unplugged
  	    return battery_plugged.timestamp > battery_unplugged.timestamp ? 'Battery Plugged' : 'Battery Unplugged'
      else
  	    return false
      end
    end
  end

  def get_gateway
    gateway = nil
    self.devices.each do |device|
      if device.device_type == "Gateway"
        gateway = device
        break
      end
    end
    gateway
  end
  
  def get_strap
    self.devices.each do |device|
      if device.device_type == 'Chest Strap'
        return device
      end
    end
    return nil
  end
  
  def get_belt_clip
    self.devices.each do |device|
      if device.device_type == 'Belt Clip'
        return device
      end
    end
    return nil
  end
  
  def get_wearable_type
    if bc = self.get_belt_clip
      bc.device_type
    elsif cs = self.get_strap
      cs.device_type
    else
      "None"
    end
  end
    
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end
  def set_active()
    self.roles_users.each do |roles_user|
      if roles_user.roles_users_option
        roles_user.roles_users_option.active = true
        roles_user.roles_users_option.save
      end
    end
  end
  
  def full_name
    return (self.profile.blank? ? "" : \
      ( self.profile.first_name && self.profile.last_name ? \
          self.profile.first_name + " " + self.profile.last_name : \
          nil
      )
    )
  end
  
  def address
    address = self.profile.address
    pcity = self.profile.city
    pstate = self.profile.state
    zipcode = self.profile.zipcode
    address && pcity && pstate && zipcode ? address + ', ' + pcity + ', ' + pstate + ' - ' + zipcode : nil
  end
  def carrier
    self.profile.cell_phone && self.profile.carrier_id ? self.profile.carrier.name : nil
  end
  def emergency_number_with_name
    self.profile.emergency_number_id ? self.profile.emergency_number.name + ' - ' + self.profile.emergency_number.number : nil
  end
  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated # this instance variable will exist when user was activated recently.
    # existing record will have data value in table column
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
  
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end
  
  def authenticated?(password)
    crypted_password == encrypt(password)
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end
  
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end
  
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def get_patients
    #   @x = Array.new
    #   for role in roles
    #    @X << [role.authorizable_id, role.Auth
    #   end
  end
  
  def patients
    patients = []
    
    RolesUser.find(:all, :conditions => "user_id = #{self.id}").each do |role_user|
      if role_user.role and role_user.role.name == 'caregiver' and role_user.roles_users_option and !role_user.roles_users_option.removed
        patients << User.find(role_user.role.authorizable_id, :include => [:roles, :roles_users, :access_logs, :profile])
      end
    end
    
    patients
  end

  # not required. this is already handled exactly like this by rails-authorization plugin
  #
  # def is_caregiver_for?(user)
  #   
  # end

  def is_active_caregiver?(caregiver)
    roles_user = self.roles_user_by_caregiver(caregiver)
    if roles_user
      opt = roles_user.roles_users_option
      if opt && !opt.removed && opt.active
        if opt.position
          caregiver[:position] = opt.position
        else
          caregiver[:position] = 1
        end
        return true
      end
    end
    return false
  end
  
  def active_caregivers
    cg_array = []
    cgs = self.caregivers
    if !cgs.nil?
      cgs.each do |caregiver|
        if self.is_active_caregiver?(caregiver)
          cg_array << caregiver
        end
      end
      cg_array.sort! do |a,b| a[:position] <=> b[:position] end
      return cg_array
    else
      return []
    end
  end
  
  def inactive_caregivers
    cg_array = []
    cgs = self.caregivers
    if !cgs.nil?
      cgs.each do |caregiver|
        if !self.is_active_caregiver?(caregiver)
          cg_array << caregiver
        end
      end
      cg_array.sort! do |a,b| a[:position] <=> b[:position] end
      return cg_array
    else
      return []
    end
  end
  def caregivers
    caregivers = []
    caregivers = self.has_caregivers
    caregivers
  end
  def roles_user_by_role(role)
    self.roles_users.find(:first, :conditions => "role_id = #{role.id}", :include => :role)
  end
  def roles_user_by_caregiver(caregiver)
    caregiver.roles_users.find(:first, :conditions => "roles.name = 'caregiver' and roles.authorizable_id = #{self.id}", :include => :role)
  end
  def roles_user_by_subscriber(subscriber)
    subscriber.roles_users.find(:first, :conditions => "roles.name = 'subscriber' and roles.authorizable_id = #{self.id}", :include => :role)
  end
  def alert_option(type)
    alert_option = nil
    roles_user = roles_user_by_role_name('halouser')
    alert_type = AlertType.find(:first, :conditions => "alert_type='#{type.class.to_s}'")
    
    if(alert_type)
      alert_option = AlertOption.find(:first, :conditions => "alert_type_id=#{alert_type.id} and roles_user_id=#{roles_user.id}")
    end
    return alert_option
  end
  # returns the user's alert options for this caregiver and type
  def alert_option_by_type(caregiver, type) 
    alert_option = nil
    roles_user = roles_user_by_caregiver(caregiver)
    alert_type = AlertType.find(:first, :conditions => "alert_type='#{type.class.to_s}'")
    
    if(alert_type)
      alert_option = AlertOption.find(:first, :conditions => "alert_type_id=#{alert_type.id} and roles_user_id=#{roles_user.id}")
    end
    return alert_option
  end
  def alert_option_by_type_operator(operator, type) 
    alert_option = nil
    roles_user = operator.roles_user_by_role_name('operator')
    alert_type = AlertType.find(:first, :conditions => "alert_type='#{type.class.to_s}'")
    
    if(alert_type)
      alert_option = AlertOption.find(:first, :conditions => "alert_type_id=#{alert_type.id} and roles_user_id=#{roles_user.id}")
    end
    return alert_option
  end
  def caregivers_sorted_by_position
    cgs = {}
    caregivers.each do |caregiver|
      roles_user = roles_user_by_caregiver(caregiver)
      if opts = roles_user.roles_users_option
        unless opts.removed
          cgs[opts.position] = caregiver
        end
      end
    end
    cgs = cgs.sort
  end
  def roles_user_by_role_name(role_name)
    if self.roles_users
      return self.roles_users.find(:first, :conditions => "roles.name = '#{role_name}' AND user_id = #{self.id}", :include => :role)
    else
      return nil
    end
  end
  
  def group_roles(options = {})
    # CHANGED: test this
    # return self.roles.find(:all, :conditions => {:authorizable_type => 'Group'}.merge(options)).uniq
    roles = self.roles.find(:all, :conditions => "authorizable_type = 'Group'")
    return roles.uniq
  end

  def groups_where_admin
    # only fetch groups for which user has admin role
    self.is_admin_of_what.select {|element| element.is_a?(Group) }.uniq
  end
  
  def group_memberships
    # # CHANGED: test this
    # # Groups for which current_user has roles
    # #   ths method is self-contained. does not depend on group_roles
    # #   also has additional check for super_admin role
    # options = ( is_super_admin? ? {} : \
    #             {:id => roles.find_all_by_authorizable_type('Group').map(&:authorizable_id).compact.uniq})
    # Group.all(:conditions => options, :order => 'name')
    # #   group roles of user, uniq, sorted
    # #   this method also works but requires "group_roles" method
    # # return group_roles.collect {|role| Group.find(role.authorizable_id) }.uniq.sort {|a, b| a <=> b}
    # 
    if is_super_admin?
      groups = Group.all
    else
      roles = group_roles
      groups = []
      if !roles.blank?
        roles.each do |role|
          groups << Group.find(role.authorizable_id)
        end
      end
      groups.sort! do |a,b|
        a.name <=> b.name
      end
      groups.uniq!
    end
    return groups
  end
  
  def group_memberships_by_role(role)
    # Group.all( :conditions => { :id => group_roles({:name => role}).collect(&:authorizable_id).compact.uniq })
    groups = []
    @role = Role.find_by_name(role)
    groups << Group.find(@role.authorizable_id)
  end
  
  def group_sales_type
    self.is_halouser_for_what.each do |group|
      if !group.nil? and group.sales_type != 'call_center'
        return group.sales_type
      end
    end
  end
  
  def group_recurring_charge
    #self.group_memberships_by_role('halouser').first.recurring_charges.length > 0 ? self.group_memberships_by_role('halouser').first.recurring_charges.first.group_charge : AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL
    
    group_charge = 0;
    
    self.is_halouser_for_what.each do |group|
      if !group.nil? and group.sales_type != 'call_center'
        if group.recurring_charges.length > 0
          group_charge = group.recurring_charges.first.group_charge
        end
      end
    end
    
    group_charge == 0 ? AUTH_NET_SUBSCRIPTION_BILL_AMOUNT_PER_INTERVAL : group_charge
    
  end
  
  def is_moderator_of_any?(groups)
    groups.each do |group|
      if self.is_moderator_of? group
        return true
      end
    end
    return false
  end
  
  def is_installer_of_any?(groups)
    groups.each do |group|
      if self.is_installer_of? group
        return true
      end
    end
    return false
  end
  def is_sales_of_any?(groups)
    groups.each do |group|
      if self.is_sales_of? group
        return true
      end
    end
    return false
  end
  def is_operator_of_any?(groups)
    groups.each do |group|
      if self.is_operator_of? group
        return true
      end
    end
    return false
  end
  
  def is_admin_of_any?(groups)
    groups.each do |group|
      if self.is_admin_of? group
        return true
      end
    end
    return false
  end
  
  def self.halo_operators
    operators = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'operator']
    halo_group = Group.find_by_name('halo')
    ops = []
    operators.each do |operator|
      if operator.is_operator_of? halo_group
        ops << operator
      end
    end
    operators = ops
    return operators
  end
  
  def self.halo_administrators
    admins = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'administrator']
    halo_group = Group.find_by_name('halo')
    adms = []
    admins.each do |admin|
      if admin.is_admin_of? halo_group
        adms << admin
      end
    end
    admins = adms
    return admins
  end
  
  def self.super_admins
    admins = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'super_admin']
    return admins
  end
  def self.administrators
    admins = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'administrator']
    return admins
  end
  
  def self.halousers
    halousers = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'halouser']
    return halousers
  end
  def self.active_operators
    os = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'operator']
    os2 = []
    os.each do |operator|
      role = operator.roles_user_by_role_name('operator')
      opt = role.roles_users_option
      if opt.blank?
        opt = RolesUsersOption.new(:roles_user_id => role.id, :active => true, :removed => false)
        opt.save!
        os2 << operator
      elsif !opt.removed && opt.active
        os2 << operator
      end
    end
    return os2
  end
  def self.operators
    os = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'operator']
    os2 = []
    os.each do |operator|
      role = operator.roles_user_by_role_name('operator')
      opt = role.roles_users_option
      if opt.blank?
        opt = RolesUsersOption.new(:roles_user_id => role.id, :active => true, :removed => false)
        opt.save!
        os2 << operator
      elsif !opt.removed
        os2 << operator
      end
    end
    return os2
  end
  
  def name()
    if(profile and !profile.last_name.blank? and !profile.first_name.blank?)
      profile.first_name + " " + profile.last_name 
    elsif !login.blank?
      login
    else 
      email
    end
  end
  
  def to_s()
    name
  end
  
  def has_phone?(user, type)
    opt = false
    if type == 'HaloUser'
      opt = true
    elsif type == 'Caregiver'
      option = self.alert_option_by_type(user, Panic.new)
      opt = option.phone_active if option
    elsif type == 'Operator'
      option = self.alert_option_by_type_operator(user, Panic.new)
      opt = option.phone_active if option
    end
    if(opt && user.profile && (!user.profile.home_phone.blank? || !user.profile.work_phone.blank? || !user.profile.cell_phone.blank?))
      return true
    else
      return false
    end
  end
  def get_cg_instruction(key, operator, caregiver)
    instructions = { 
      CallCenterWizard::CAREGIVER_MOBILE_PHONE => "Mobile " + format_phone(caregiver.profile.cell_phone) + "?",
      CallCenterWizard::CAREGIVER_HOME_PHONE   => "Home " + format_phone(caregiver.profile.home_phone) + "?",
      CallCenterWizard::CAREGIVER_WORK_PHONE   => "Work " + format_phone(caregiver.profile.work_phone) + "?",
      CallCenterWizard::CAREGIVER_ACCEPT_RESPONSIBILITY      => "Accept responsibility?",
      CallCenterWizard::CAREGIVER_AT_HOUSE     => "At House?",
      CallCenterWizard::CAREGIVER_GO_TO_HOUSE  => "Can you go to house?",
      CallCenterWizard::ON_BEHALF_GO_TO_HOUSE  => "Go to house and press GW button",
      CallCenterWizard::CAREGIVER_THANK_YOU    => "Thank You!",
      CallCenterWizard::AMBULANCE              => "Is Ambulance Needed?",
      CallCenterWizard::ON_BEHALF              => "Will you call 911 on behalf of #{self.name}?",
      CallCenterWizard::THANK_YOU_PRE_AGENT_CALL_911 => "Thank You, Agent will call.",
      CallCenterWizard::PRE_AGENT_CALL_911     => "Can you call an ambulance?",
      CallCenterWizard::AGENT_CALL_911         => "Ambulance dispatched properly?",
      CallCenterWizard::AMBULANCE_DISPATCHED   => "Ambulance dispatched.",
      CallCenterWizard::CAREGIVER_GOOD_BYE     => "Thank You.  Good Bye.",
      CallCenterWizard::THE_END                => "Resolved the Event",
      CallCenterWizard::RECONTACT_CAREGIVER => "Recontact Caregiver Home" + format_phone(caregiver.profile.home_phone) + "?",
      CallCenterWizard::RECONTACT_CAREGIVER_ACCEPT_RESPONSIBILITY => 'Recontact Caregiver Accept Responsibility',
      CallCenterWizard::RECONTACT_CAREGIVER_ABLE_TO_RESET => "Caregiver Able to Reset Gateway.",
      CallCenterWizard::RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET => "Caregiver is not Able to Reset Gateway.",
      CallCenterWizard::RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET_CONTINUE => "Caregiver Able to Reset Gateway.",
      CallCenterWizard::CALL_HALO_ADMIN => "Call Halo Admin."
    }
    instruction = instructions[key]
    return instruction
  end
  def get_instruction(key, operator)
    instructions = { 
      CallCenterWizard::USER_HOME_PHONE        => "Home " + format_phone(self.profile.home_phone) + "?",
      CallCenterWizard::USER_MOBILE_PHONE      => "Mobile " + format_phone(self.profile.cell_phone)+ "?",
      CallCenterWizard::USER_OK                => "Call caregivers?",
      CallCenterWizard::USER_AMBULANCE         => "Agent to dispatch ambulance?",
      CallCenterWizard::ON_BEHALF              => "Will you call 911 on behalf of #{self.name}?",
      CallCenterWizard::PRE_AGENT_CALL_911     => "Can dispatcher dispatch an ambulance?",
      CallCenterWizard::AGENT_CALL_911         => "Ambulance dispatched properly?",
      CallCenterWizard::AMBULANCE_DISPATCHED   => "Ambulance dispatched.",
      CallCenterWizard::USER_GOOD_BYE          => "Thank You.  Good Bye.",
      CallCenterWizard::THE_END                => "Resolved the Event",
      CallCenterWizard::RECONTACT_USER => "Recontact User?",
      CallCenterWizard::RECONTACT_USER_OK => 'Recontact OK.',
      CallCenterWizard::RECONTACT_USER_ABLE_TO_RESET => "User Able to Reset Gateway.",
      CallCenterWizard::RECONTACT_USER_NOT_ABLE_TO_RESET =>  "User is Not Able to Reset Gateway.",
      CallCenterWizard::RECONTACT_USER_NOT_ABLE_TO_RESET_CONTINUE =>  "User Able to Reset Gateway.",
      CallCenterWizard::HELP_COMING_SOON =>  "Help Coming Soon.",
      CallCenterWizard::AMBULANCE_COMING_SOON =>  "Help coming soon.",
      CallCenterWizard::CALL_HALO_ADMIN => "Call Halo Admin."
    }
    instruction = instructions[key]
    return instruction
  end
  def get_cg_script(key, operator, caregiver, event)
    now = Time.now
    minutes = ((now - event.timestamp_server) / (60)).round
    scripts = {
      CallCenterWizard::CAREGIVER_MOBILE_PHONE => get_able_to_reach_script_cell(caregiver, "Caregiver"),      
      CallCenterWizard::CAREGIVER_HOME_PHONE   => get_able_to_reach_script_home(caregiver, "Caregiver"),
      CallCenterWizard::CAREGIVER_WORK_PHONE   => get_able_to_reach_script_work(caregiver, "Caregiver"),
      CallCenterWizard::CAREGIVER_ACCEPT_RESPONSIBILITY      => get_caregiver_responisibility_script(caregiver, event, operator),
      CallCenterWizard::CAREGIVER_AT_HOUSE     => get_caregiver_are_you_at_house_script(caregiver),
      CallCenterWizard::CAREGIVER_GO_TO_HOUSE  => get_caregiver_go_to_house_script(caregiver),
      CallCenterWizard::ON_BEHALF_GO_TO_HOUSE  => get_on_behalf_script_orig(self.profile.first_name),
      CallCenterWizard::CAREGIVER_THANK_YOU    => get_caregiver_thank_you_script(caregiver),
      CallCenterWizard::AMBULANCE              => get_caregiver_script(caregiver, operator, event),
      CallCenterWizard::ON_BEHALF              => get_on_behalf_script(self.profile.first_name),
      CallCenterWizard::THANK_YOU_PRE_AGENT_CALL_911 => get_thank_you_pre_agent(),
      CallCenterWizard::PRE_AGENT_CALL_911     => get_ambulance_start_script(operator, event),
      CallCenterWizard::AGENT_CALL_911         => get_ambulance_script(operator, event),      
      CallCenterWizard::AMBULANCE_DISPATCHED   => get_ambulance_dispatched(),
      CallCenterWizard::CAREGIVER_GOOD_BYE     => get_caregiver_good_bye_script(),
      CallCenterWizard::THE_END                => "Please click <a style=\"color: white;\" href=\"/call_center/resolved/#{event.id}\">here to Resolve</a> the event.",
      CallCenterWizard::RECONTACT_CAREGIVER => get_caregiver_recontact(minutes),
      CallCenterWizard::RECONTACT_CAREGIVER_ACCEPT_RESPONSIBILITY => get_caregiver_recontact_responsibilty(),
      CallCenterWizard::RECONTACT_CAREGIVER_ABLE_TO_RESET => get_caregiver_able_to_reset(),
      CallCenterWizard::RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET => get_caregiver_not_able_to_reset(),
      CallCenterWizard::RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET_CONTINUE => get_caregiver_not_able_to_reset_continue(),
      CallCenterWizard::CALL_HALO_ADMIN => get_call_halo_admin()
    }
    script = scripts[key]
    return script
  end
  
  def get_script(key, operator, event)
    now = Time.now
    minutes = ((now - event.timestamp_server) / (60)).round
    scripts = {
      CallCenterWizard::USER_HOME_PHONE        => get_able_to_reach_script_home(self, "HaloUser"),
      CallCenterWizard::USER_MOBILE_PHONE      => get_able_to_reach_script_cell(self, "HaloUser"),
      CallCenterWizard::USER_AMBULANCE         => get_user_script(operator, event, self.profile.home_phone),
      CallCenterWizard::USER_OK                => get_user_ok_script(operator, event),
      CallCenterWizard::ON_BEHALF              => get_on_behalf_script(self.profile.first_name),
      CallCenterWizard::PRE_AGENT_CALL_911     => get_ambulance_start_script(operator, event),
      CallCenterWizard::AGENT_CALL_911         => get_ambulance_script(operator, event),      
      CallCenterWizard::AMBULANCE_DISPATCHED   => get_ambulance_dispatched(),
      CallCenterWizard::USER_GOOD_BYE          => get_user_good_bye_script,
      CallCenterWizard::THE_END                => "Please click <a style=\"color: white;\" href=\"/call_center/resolved/#{event.id}\">here to Resolve</a> the event.",
      CallCenterWizard::RECONTACT_USER => get_user_recontact(minutes, operator),
      CallCenterWizard::RECONTACT_USER_OK => get_user_recontact_ok(),
      CallCenterWizard::RECONTACT_USER_ABLE_TO_RESET => get_user_able_to_reset(),
      CallCenterWizard::RECONTACT_USER_NOT_ABLE_TO_RESET => get_user_not_able_to_reset(),
      CallCenterWizard::RECONTACT_USER_NOT_ABLE_TO_RESET_CONTINUE => get_user_not_able_to_reset_continue(),
      CallCenterWizard::HELP_COMING_SOON => get_help_coming_soon(),
      CallCenterWizard::AMBULANCE_COMING_SOON => get_help_coming_soon(),
      CallCenterWizard::CALL_HALO_ADMIN => get_call_halo_admin()
        }
        script = scripts[key]
        return script
  end 
  
  # email = caregiver email
  # seniod_id = senior id
  # return variable = caregiver object
  def self.populate_caregiver(email,senior_id=nil, position = nil,login = nil,profile_hash = nil)#, roles_users_hash = {})
    existing_user = User.find_by_email(email)
    if !login.nil? and login != ""
      @user = User.find_by_login(login)
      @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    elsif !existing_user.nil? 
      @user = existing_user
      @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    else
      @user = User.new
      @user.email = email
    end
    
    if !@user.email.blank?
      @user.is_new_caregiver = true
      @user[:is_caregiver] = true
      @user.save!

      if @user.profile.blank?
        if profile_hash.blank?
          profile = Profile.new(:user_id => @user.id)
        else
          if profile_hash.is_a?( Profile)
            profile = profile_hash # its Profile instance already
          elsif profile_hash.is_a?( Hash)
            profile = Profile.new(profile_hash)
          end
        end
        profile[:is_new_caregiver] = true
        if profile.valid? && profile.save!
          @user.profile = profile
        end
      end
      senior = User.find(senior_id)

      if position.blank?
        position = self.get_max_caregiver_position(senior)
      end
      
      role = @user.has_role 'caregiver', senior #if 'caregiver' role already exists, it will return nil
      
      if !role.nil? #if role.nil? then the roles_user does not exist already
        @roles_user = senior.roles_user_by_caregiver(@user)

        self.update_from_position(position, @roles_user.role_id, @user.id)
        #enable_by_default(@roles_user)      
        RolesUsersOption.create(:roles_user_id => @roles_user.id, :position => position, :active => 0)#, :email_active => (roles_users_hash["email_active"] == "1"), :is_keyholder => (roles_users_hash["is_keyholder"] == "1"))
      end
      UserMailer.deliver_caregiver_email(@user, senior)
    end
    @user
  end
  
  def self.resend_mail(id,senior)
    @user = User.find(id)
    @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    @user.save
    @senior = User.find(senior)
    UserMailer.deliver_caregiver_email(@user, @senior)
  end
  
  def self.get_max_caregiver_position(user)
    #get_caregivers(user)
    #@caregivers.size + 1  #the old method would not work if a position num was skipped
    max_position = 1
    user.caregivers.each do |caregiver|
      roles_user = user.roles_user_by_caregiver(caregiver)
      if opts = roles_user.roles_users_option
        if opts.position >= max_position
          max_position = opts.position + 1
        end
      end
    end
    return max_position
  end
  
  def self.update_from_position(position, roles_user_id, user_id)
    caregivers = RolesUsersOption.find(:all, :conditions => "position >= #{position} and roles_user_id = #{roles_user_id}")
    
    caregivers.each do |caregiver|
      caregiver.position+=1
      caregiver.save
    end
  end
  
  def get_call_halo_admin()
      info = <<-eos 
        <div style="font-size: x-large"><font color="white">"Call Halo Admin in <a href="/call_center/faq">FAQ</a>."</div>
        eos
      return info
    
  end
  def get_help_coming_soon()
      info = <<-eos 
        <font color="white">Recite this script:</font><br>
        <i><div style="font-size: 150%; color: yellow;">"There will be somebody there to help you soon. If we can't reach your caregivers, we will dispatch an ambulance. Goodbye."</div></i>
        eos
      return info
  end
  def get_user_able_to_reset()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"If you’re not able to press the Gateway reset button, we will be calling you back at this number. Thank you. Goodbye"</div></i>
    eos
    return info
  end
  def get_user_not_able_to_reset_continue()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"If you’re not able to press the Gateway reset button, we will be calling you back at this number. Thank you. Goodbye"</div></i>
    eos
    return info
  end
  def get_user_not_able_to_reset()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"The Halo Gateway is a black box, probably near the computer or internet router. It has green and red lights and says Halo on it. If it is still beeping, please press the red button to reset it."</div></i>
    eos
    return info
  end
  def get_user_recontact_ok()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Will you be able to locate and press the red alarm reset button on the Halo gateway for #{name}? It will be beeping loudly."</div></i>
    eos
    return info
  end
  
  def get_user_recontact(minutes, operator)
    first_name = ''
    first_name = self.profile.first_name if self.profile && self.profile.first_name
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"My name is #{operator.name} calling on behalf of Halo Monitoring. We are calling to follow up #{name}’s fall. We have detected that no one has pushed the alarm reset button on #{first_name}'s Halo Gateway. Can you please verify that #{first_name}'s Fall has been successfully resolved?"</div></i>
    eos
    return info
  end
  def get_caregiver_recontact_responsibilty()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Will you be able to locate and press the red alarm reset button on the Halo gateway for #{name}?. It will be beeping loudly."</div></i>
    eos
    return info
  end
  
  def get_caregiver_able_to_reset()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"If you’re not able to press the Gateway reset button, we will be calling you back at this number. Thank you. Goodbye"</div></i>
    eos
    return info
  end
  def get_caregiver_not_able_to_reset_continue()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"If you’re not able to press the Gateway reset button, we will be calling you back at this number. Thank you. Goodbye"</div></i>
    eos
    return info
  end
  def get_caregiver_not_able_to_reset()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"The Halo Gateway is a black box, probably near the computer or internet router. It has green and red lights and says Halo on it. If it is still beeping, please press the red button to reset it."</div></i>
    eos
    return info
  end
  def get_caregiver_recontact(minutes)
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"We called you #{minutes} minutes ago about #{name}’s fall. We have detected that no one has pushed the alarm reset button on your Halo Gateway. Can you please verify that #{name} is safe and been attended to?"</div></i>
    eos
    return info
  end
  def get_user_good_bye_script()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Please make sure that the red reset button on the gateway device is pressed.  The Halo Gateway is a black box, probably near the computer or internet router. It has green and red lights and says Halo on it. If it is still beeping, please press the red button to reset it.  Thank You.  Good Bye."</div></i>
    eos
    return info
  end
  
  def get_caregiver_good_bye_script()
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Please make sure that the red reset button on the gateway device is pressed.  The Halo Gateway is a black box, probably near the computer or internet router. It has green and red lights and says Halo on it. If it is still beeping, please press the red button to reset it.  Thank You.  Good Bye."</div></i>
    eos
    return info
  end
  
  def get_ambulance_dispatched
    info = <<-eos
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"I would like to verify the street address we have on file for #{self.name}. Are you ready?"</div></i>
      <br>
      <br>
      (wait for caregiver)
      <br>
      <br>
      <i><div style="font-size: 150%; color: yellow;">"The street address is<br>
                               #{self.profile.address}<br>
                               #{self.profile.city}, #{self.profile.state} #{self.profile.zipcode}"</div></i><br>
      <br>
      <br>
      (wait for caregiver to finish)
      <br>
      <br>
      <i><div style="font-size: 150%; color: yellow;"></div></i>
    eos
    return info
  end
  def get_caregiver_thank_you_script(caregiver)
    caregivers = self.active_caregivers
    next_caregiver = false
    ncg = nil
    caregivers.each do |cg|
      if next_caregiver == true
        ncg = cg
        next_caregiver = false
      end
      if cg == caregiver
        next_caregiver = true
      end      
    end
    caregiver_name = ''
    caregiver_name = ncg.name if ncg
    if !caregiver_name.blank?
      info = <<-eos 
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"Thank You.  We will be contacting #{caregiver_name}, the next caregiver.  Good Bye."</div></i>
      eos
      return info
    else  service_name = 'local emergency service'
      service_name = self.profile.emergency_number.name if self.profile.emergency_number
      info = <<-eos 
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"Thank You.  We will now be calling #{service_name} to dispatch an amublance. Good Bye."</div></i>
      eos
      return info
    
    end
  end
  def get_thank_you_pre_agent
    service_name = 'local emergency service'
    service_name = self.profile.emergency_number.name if self.profile.emergency_number
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Thank You.  We will now be calling #{service_name} to dispatch an amublance. Good Bye."</div></i>
    eos
    return info
  end
  def get_user_ok_script(operator,event)
    info = ''
    event_type = event.event_type
    if event_type == CallCenterFollowUp.class_name
      event_type = get_event_type(event)
    end
    if !self.active_caregivers.blank?
      info = <<-eos 
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"Hello #{self.profile.first_name}, my name is #{operator.name} representing Halo Monitoring. We have detected a #{event_type}. Would you like us to call your caregivers to help you?"</div></i>
      eos
    else
      info = <<-eos 
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"Hello #{self.profile.first_name}, my name is #{operator.name} representing Halo Monitoring. We have detected a #{event_type}. Would you like us to dispatch an ambulance for you?"</div></i>
      eos
    end
    return info
  end
  def get_caregiver_responisibility_script(caregiver, event, operator)
    event_type = event.event_type
    if event_type == CallCenterFollowUp.class_name
      event_type = get_event_type(event)
    end
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">Hello #{caregiver.profile.first_name}, my name is #{operator.name} representing Halo Monitoring. We have detected a #{event_type} for #{self.name}. Do you accept responsibility for handling #{self.name}'s #{event_type}?</div></i>
    eos
    return info
  end
  def get_caregiver_are_you_at_house_script(caregiver)
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">Are you at #{self.profile.first_name}'s house?</div></i>
    eos
    return info
  end
  def get_caregiver_go_to_house_script(caregiver)
    info = <<-eos 
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">Can you go to #{self.profile.first_name}'s house to determine if #{self.name} is OK?</div></i>
    eos
    return info
  end
  def get_able_to_reach_script_work(user, role)
    opt = false
    if role == 'HaloUser'
      opt = true
    elsif role == 'Caregiver'
      option = self.alert_option_by_type(user, Panic.new)
      opt = option.phone_active if option
    elsif role == 'Operator'
      option = self.alert_option_by_type_operator(user, Panic.new)
      opt = option.phone_active if option
    end
    if user && user.profile && !user.profile.work_phone.blank? && opt
      return get_able_to_reach_script(user.profile.work_phone, role, user.name, "Work")
    else
      return nil
    end
  end
  
  def get_able_to_reach_script_cell(user, role)
    opt = false
    if role == 'HaloUser'
      opt = true
    elsif role == 'Caregiver'
      option = self.alert_option_by_type(user, Panic.new)
      opt = option.phone_active if option
    elsif role == 'Operator'
      option = self.alert_option_by_type_operator(user, Panic.new)
      opt = option.phone_active if option
    end
    if user && user.profile && !user.profile.cell_phone.blank? && opt
      return get_able_to_reach_script(user.profile.cell_phone, role, user.name, "Mobile")
    else
      return nil
    end
  end
  
  def get_able_to_reach_script_home(user, role)
    opt = false
    if role == 'HaloUser'
      opt = true
    elsif role == 'Caregiver'
      option = self.alert_option_by_type(user, Panic.new)
      opt = option.phone_active if option
    elsif role == 'Operator'
      option = self.alert_option_by_type_operator(user, Panic.new)
      opt = option.phone_active if option
    end
    if user && user.profile && !user.profile.home_phone.blank? && opt
      return get_able_to_reach_script(user.profile.home_phone, role, user.name, "Home")
    else
      return nil
    end
  end
  
  def get_able_to_reach_script(phone, role, name, place)
    info = <<-eos 
      <div style="font-size: x-large"><font color="white">Call #{role} <b>#{name}</b> at #{place} <b>#{format_phone(phone)}</b></font></div>
      <br><br>
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"Can I speak to #{name}?"</div></i>
      <br><br>
      Were you able to reach #{name} at #{place}?
      eos
    return info
  end
  
  def get_user_script(operator, event, phone)
    info = <<-eos
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Would you like us to dispatch an ambulance for you?"
    </div></i>
    eos
    return info
  end
  
  def get_caregiver_script(caregiver, operator, event)
    caregivers = self.active_caregivers
    next_caregiver = false
    ncg = nil
    caregivers.each do |cg|
      if next_caregiver == true
        ncg = cg
        next_caregiver = false
      end
      if cg == caregiver
        next_caregiver = true
      end      
    end
    caregiver_name = ''
    caregiver_name = ncg.name if ncg
    if !caregiver_name.blank?
      info = <<-eos
      <font color="white">Recite this script:</font><br>
      <i><div style="font-size: 150%; color: yellow;">"Would you like for an ambulance to be dispatched for #{self.name}?"
      </div></i>
      eos
      return info
    else
        info = <<-eos
        <font color="white">Recite this script:</font><br>
        <i><div style="font-size: 150%; color: yellow;">"Would you like for an ambulance to be dispatched for #{self.name}?"
        </div></i>
        eos
        return info      
    end
  end
  def get_on_behalf_script(name)
    info = <<-eos
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Can you call 911 on behalf of #{name}?
    </div></i>
    eos
    return info
  end
  def get_on_behalf_script_orig(name)
    info = <<-eos
    <font color="white">Recite this script:</font><br>
    <i><div style="font-size: 150%; color: yellow;">"Please make sure that the red reset button on the gateway device is pressed.  The Halo Gateway is a black box, probably near the computer or internet router. It has green and red lights and says Halo on it. If it is still beeping, please press the red button to reset it.  Thank You.  Good Bye."
    </div></i>
    eos
    return info
  end
  def get_ambulance_start_script(operator, event)
    event_type = event.event_type
    if event_type == CallCenterFollowUp.class_name
      event_type = get_event_type(event)
    end
    service_name = 'local emergency service'
    service_name = self.profile.emergency_number.name if self.profile.emergency_number
    number = ''
    number = self.profile.emergency_number.number if self.profile.emergency_number
    info = <<-eos
    <div style="font-size: x-large"><b><font color="white">Call #{service_name} at #{number}</font></b></div>
    <br><br>
    <font color="white">Recite this script:</font><br><br>
    <i><div style="font-size: 150%; color: yellow;">"My name is #{operator.name} representing Halo Monitoring. We have  
    detected a #{event_type} for #{self.name} and have the approval to dispatch an  
    ambulance. Can you dispatch an ambulance?”</div></i>
    <br><br>
    eos
    return info
  end
  def get_event_type(event)
    follow_up = CallCenterFollowUp.find(event.event_id)
    event_type = follow_up.event.event_type
    if event_type == CallCenterFollowUp.class_name
      event_type = get_event_type(follow_up.event)
    else
      return event_type
    end
  end
  def get_ambulance_script(operator, event)
    service_name = 'local emergency service'
    service_name = self.profile.emergency_number.name if self.profile.emergency_number
    number = ''
    number = self.profile.emergency_number.number if self.profile.emergency_number
    info = <<-eos
    <font color="white">Recite this script:</font><br><br>
    <i><div style="font-size: 150%; color: yellow;">"Please send amublance to<br>
    <br>
    #{self.profile.address}<br>
    #{self.profile.city}, #{self.profile.state} #{self.profile.zipcode}<br>"
    </div></i>
    <br><br>
    <i><div style="font-size: 150%; color: yellow;">#{self.vitals_text}</div></i>
    <br><br>
    Was the ambulance dispatched properly?
    eos
    return info
  end
  def vitals_text
    vital = Vital.find(:first, :conditions => "user_id = #{self.id} AND heartrate <> -1", :order => 'timestamp desc')
    skintemp = SkinTemp.find(:first, :conditions => "user_id = #{self.id} AND skin_temp <> -1 AND skin_temp <> 0", :order => 'timestamp desc')
    if vital && skintemp &&  vital.timestamp && skintemp.timestamp
        return "\"#{self.name}'s vitals are:  <br>heartrate: #{vital.heartrate} bpm (as of #{vital.timestamp.to_s})  <br>current skin temp:  #{skintemp.skin_temp} F (as of #{skintemp.timestamp})\""
    end
  end
  def format_phone(number)
    number.blank? ? "N/A" : format_phone_add_dashes(number.strip)
  end
  def format_phone_add_dashes(number)
    if number.size == 10
      return number[0,3] + '-' + number[3,3] + '-' + number[6,4]
    elsif(number.size == 7)
      return number[3,3] + '-' + number[6,4]
    else
      return number
    end
  end
  
  def contact_info_table()
    info = <<-eos
      <table><tr><td colspan="2">#{name}</td></tr>
             <tr><td>Home</td><td>#{format_phone(profile.home_phone)}</td></tr>
             <tr><td>Cell</td><td>#{format_phone(profile.cell_phone)}</td></tr>
            <tr><td>Work</td><td>#{format_phone(profile.work_phone)}</td></tr>
      </table>
    eos
    return info
  end
  def contact_info()
    name + ": Home #{format_phone(profile.home_phone)} | Cell #{format_phone(profile.cell_phone)} | Work #{format_phone(profile.work_phone)}"  
  end
  def phone_numbers()
    info = <<-eos
      <table>
             <tr><td>Home</td><td>#{format_phone(profile.home_phone)}</td></tr>
             <tr><td>Cell</td><td>#{format_phone(profile.cell_phone)}</td></tr>
            <tr><td>Work</td><td>#{format_phone(profile.work_phone)}</td></tr>
      </table>
    eos
    return info
  end
  def contact_info_by_alert_option(alert_option)
    if opts = alert_option.roles_user.roles_users_option
      unless opts.removed
         info = "(#{opts.position}) " + contact_info()
         return info += (opts.is_keyholder? ? " | Key holder" : " | Non-key holder")
      end
    end
  end
  
  # sets the instance variable @is_caregiver to the value of b
  def is_new_caregiver=(b=false)
    @is_caregiver= b
  end
  
  # returns the instance variable @is_caregiver
  def is_new_caregiver
    return @is_caregiver
  end
  
  # returns the users main role
  # as determined by the role with the greatest permissions
  def main_role
    if self.is_super_admin?
      return 'super_admin'
    elsif self.is_admin?
      return 'admin'
    elsif self.is_operator?
      return 'operator'
    elsif self.is_halouser?
      return 'halouser'
    elsif self.is_caregiver?
      return 'caregiver'
    end
    return ''
  end
  def self.create_operator(user_params, profile_params)
    ems_group = Group.find_by_name('EMS')
    login = user_params[:login]
    user = User.find_by_login(login)
    unless user
      user = User.new(user_params)
      user.save!
      profile = Profile.new(profile_params)
      profile.user_id = user.id
      profile.save!
      user.activate
      user.is_operator_of ems_group
      user.save!    
    end
  end
  protected
  
  # before filter
  # Sets the salt and encrypts the password 
  def encrypt_password
    unless password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
  end
  
  # returns true if password is a required field
  def password_required?
    # WARNING: DEPRECATED :is_new_halouser, :is_new_user, :is_new_subscriber, :is_new_caregiver
    # CHANGED: we can now use user_intake object to create users and profiles
    # example:
    #  profile_attributes = Profile.new({...}).attributes
    #  user_attributes = User.new({..., :profile_attributes => profile_attributes}).attributes
    #  user_intake = UserIntake.new(:senior_attributes => user_attributes) # includes profile attributes
    #    or
    #  user_intake = UserIntake.new(:senior_attributes => User.new({:email => ..., :profile_attributes => Profile.new({...}).attributes}).attributes)
    if(skip_validation || self.is_new_caregiver || self[:is_new_user] || self[:is_new_subscriber] || self[:is_new_halouser])
      return false
    else
      crypted_password.blank? || !password.blank?
    end
  end
  
  # generates activation code
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end 
  
  # return true if the login is not blank
  def login_not_blank?
    return (skip_validation ? false : !self.login.blank?)
  end
  
  private # ------------------------------ private methods
  
  def skip_associations_validation
    self.profile.send("skip_validation=", skip_validation) unless profile.blank?
  end
  
end
