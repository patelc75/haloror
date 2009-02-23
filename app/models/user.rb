require 'digest/sha1'
class User < ActiveRecord::Base
  #composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  
  acts_as_authorized_user
  acts_as_authorizable
  has_many :notes
  has_many :panics
  has_many :batteries
  has_many :falls  
  has_many :events
  has_many :skin_temps
  has_one  :profile
  has_many :steps
  has_many :vitals
  has_many :halo_debug_msgs
  has_many :mgmt_cmds
  #belongs_to :role
  #has_one :roles_user
  #has_one :roles_users_option
  
  has_many :roles_users
  has_many :roles, :through => :roles_users#, :include => [:roles_users]
  
  has_and_belongs_to_many :devices
  
  has_many :access_logs
  
  has_many :event_actions
  
  #has_many :call_orders, :order => :position
  #has_many :caregivers, :through => :call_orders #self referential many to many
  
  # Virtual attribute for the unencrypted password
  cattr_accessor :current_user #stored in memory instead of table
  attr_accessor :password
  attr_accessor :current_password
  validates_presence_of     :login, :if => :password_required?
  validates_presence_of     :email
  #validates_presence_of     :serial_number
  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  
  validates_length_of       :login,    :within => 3..40, :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  #validates_length_of       :serial_number, :is => 10
  
  validates_uniqueness_of   :login, :case_sensitive => false, :if => :login_not_blank?
  
  before_save :encrypt_password
  before_create :make_activation_code
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  #attr_accessible :login, :email, :password, :password_confirmation
  
  
  def get_strap
    self.devices.each do |device|
      if device.device_type == 'Chest Strap'
        return device
      end
    end
    return nil
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
  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
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
    # 	@x = Array.new
    # 	for role in roles
    # 	 @X << [role.authorizable_id, role.Auth
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
  def is_caregiver_for?(user)
    
  end
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
    caregiver.roles_users.find(:first, :conditions => "roles.authorizable_id = #{self.id}", :include => :role)
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
  def group_roles
    roles = self.roles.find(:all, :conditions => "authorizable_type = 'Group'")
    return roles.uniq
  end
  def group_memberships
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
    return groups
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
      CallCenterWizard::ON_BEHALF_GO_TO_HOUSE  => "Arrive at house, call 911?",
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
      CallCenterWizard::RECONTACT_CAREGIVER_ACCEPT_RESPONSIBILITY => 'Recontact Caregiver Accept Responsibility'
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
      CallCenterWizard::RECONTACT_USER_OK => 'Recontact OK.'
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
      CallCenterWizard::RECONTACT_CAREGIVER_ACCEPT_RESPONSIBILITY => get_caregiver_recontact_responsibilty()
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
      CallCenterWizard::RECONTACT_USER => get_user_recontact(minutes),
      CallCenterWizard::RECONTACT_USER_OK => get_user_recontact_ok()
    }
    script = scripts[key]
    return script
  end 
  
  def get_user_recontact_ok()
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">"Can you please press the reset button on your gateway device. It will be beeping loudly.  Thank You Good Bye."</div></i>
	  eos
    return info
  end
  
  def get_caregiver_recontact_responsibilty()
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">"Can you please press the reset button on #{name}'s gateway device. It will be beeping loudly. Thank You Good Bye."</div></i>
	  eos
    return info
  end
  
  def get_user_recontact(minutes)
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">We called you #{minutes} minutes ago about your fall. We have detected that no one has pushed the alarm reset button on your Halo Gateway</div></i>
	  eos
    return info
  end
  def get_caregiver_recontact(minutes)
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">"We called you #{minutes} minutes ago about #{self.name}’s fall. We have detected that no one has pushed the alarm reset button on #{self.name}’s Halo Gateway."</div></i>
	  eos
    return info
  end
  def get_user_good_bye_script()
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">"Please make sure that the reset button on the gateway device is pressed.  Thank You.  Good Bye."</div></i>
	  eos
    return info
  end
  
  def get_caregiver_good_bye_script()
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">"Please make sure that the reset button on the gateway device is pressed.  Thank You.  Good Bye."</div></i>
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
    else  service_name = '911 or local emergency service'
      service_name = self.profile.emergency_number.name if self.profile.emergency_number
      info = <<-eos	
  	  <font color="white">Recite this script:</font><br>
  	  <i><div style="font-size: 150%; color: yellow;">"Thank You.  We will now be calling #{service_name} to dispatch an amublance. Good Bye."</div></i>
  	  eos
      return info
    
    end
  end
  def get_thank_you_pre_agent
    service_name = '911 or local emergency service'
    service_name = self.profile.emergency_number.name if self.profile.emergency_number
    info = <<-eos	
	  <font color="white">Recite this script:</font><br>
	  <i><div style="font-size: 150%; color: yellow;">"Thank You.  We will now be calling #{service_name} to dispatch an amublance. Good Bye."</div></i>
	  eos
    return info
  end
  def get_user_ok_script(operator,event)
    info = ''
    if !self.active_caregivers.blank?
      info = <<-eos	
  	  <font color="white">Recite this script:</font><br>
  	  <i><div style="font-size: 150%; color: yellow;">"Hello #{self.profile.first_name}, my name is #{operator.name} representing Halo Monitoring We have detected a #{event.event_type}. Would you like us to call your caregivers to help you?"</div></i>
  	  eos
	  else
	    info = <<-eos	
  	  <font color="white">Recite this script:</font><br>
  	  <i><div style="font-size: 150%; color: yellow;">"Hello #{self.profile.first_name}, my name is #{operator.name} representing Halo Monitoring We have detected a #{event.event_type}. Would you like us to dispatch an ambulance for you?"</div></i>
  	  eos
    end
    return info
  end
  def get_caregiver_responisibility_script(caregiver, event, operator)
    info = <<-eos	
  	<font color="white">Recite this script:</font><br>
  	<i><div style="font-size: 150%; color: yellow;">Hello #{caregiver.profile.first_name}, my name is #{operator.name} representing Halo Monitoring We have detected a #{event.event_type} for #{self.name}. Do you accept responsibility for handling #{self.name}'s #{event.event_type}?</div></i>
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
		<i><div style="font-size: 150%; color: yellow;">"When you arrive at the home, can you please call 911 on behalf of #{name}? After that, can you please press the reset button on #{name}'s gateway device. It will be beeping loudly."
		</div></i>
		eos
    return info
  end
  def get_ambulance_start_script(operator, event)
    service_name = '911 or local emergency service'
    service_name = self.profile.emergency_number.name if self.profile.emergency_number
    number = '911'
    number = self.profile.emergency_number.number if self.profile.emergency_number
    info = <<-eos
		<div style="font-size: x-large"><b><font color="white">Call #{service_name} at #{number}</font></b></div>
		<br><br>
		<font color="white">Recite this script:</font><br><br>
		<i><div style="font-size: 150%; color: yellow;">"My name is #{operator.name} representing Halo Monitoring. We have  
    detected a #{event.event_type} for #{self.name} and have the approval to dispatch an  
    ambulance. Can you dispatch an ambulance?”</div></i>
    <br><br>
    eos
    return info
  end
  def get_ambulance_script(operator, event)
    service_name = '911 or local emergency service'
    service_name = self.profile.emergency_number.name if self.profile.emergency_number
    number = '911'
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
        "(#{opts.position}) " + contact_info()
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
  
  protected
  
  # before filter
  # Sets the salt and encrypts the password 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  # returns true if password is a required field
  def password_required?
    if(self.is_new_caregiver || self.is_new_user)
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
    return !self.login.blank?
  end
  
  
end
