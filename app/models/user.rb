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
  def self.administrators
    admins = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'administrator']
    return admins
  end
  
  def self.halousers
    halousers = User.find :all, :include => {:roles_users => :role}, :conditions => ["roles.name = ?", 'halouser']
    return halousers
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
  
  
  def get_instruction(key, operator, caregiver)
    instructions = { 
      CallCenterWizard::USER_HOME_PHONE        => format_phone(self.profile.home_phone),
      CallCenterWizard::USER_MOBILE_PHONE      => format_phone(self.profile.cell_phone),
      CallCenterWizard::CAREGIVER_HOME_PHONE   => format_phone(caregiver.profile.home_phone),
      CallCenterWizard::CAREGIVER_WORK_PHONE   => format_phone(caregiver.profile.work_phone),
      CallCenterWizard::AMBULANCE              => "Is Ambulance Needed?",
      CallCenterWizard::ON_BEHALF              => "Will you call 911 on behalf of #{self.name}?",
      CallCenterWizard::AGENT_CALL_911         => "",
      CallCenterWizard::AMBULANCE_DISPATCHED   => "",
      CallCenterWizard::THE_END                => "Resolve the Event"
      }
    instruction = instructions[key]
    return instruction
  end
  
  def get_script(key, operator, caregiver, event)
    scripts = {
      CallCenterWizard::USER_HOME_PHONE        =>  get_user_phone(operator, event),
      CallCenterWizard::USER_MOBILE_PHONE      => format_phone(self.profile.cell_phone),
      CallCenterWizard::CAREGIVER_HOME_PHONE   => "caregiver home phone",
      CallCenterWizard::CAREGIVER_WORK_PHONE   => "caregiver work phone",
      CallCenterWizard::AMBULANCE              => "Is Ambulance Needed?",
      CallCenterWizard::ON_BEHALF              => "Will you call 911 on behalf of #{self.name}?",
      CallCenterWizard::AGENT_CALL_911         => "agent call 911?",
      CallCenterWizard::AMBULANCE_DISPATCHED   => "ambulance dispatched?",
      CallCenterWizard::THE_END                => "Please click <a href=\"/call_center/resolved/#{event.id}\">here to Resolve</a> the event."
    }
    script = scripts[key]
    return script
  end 
  def get_user_phone()
    info = <<-eos
											      <div style="font-size: xx-large"><b><font color="white">Call HaloUser #{self.name} at #{format_phone(self.profile.home_phone)}</font></b></div>
												  <br><br>
											      <font color="white">Recite this script:</font><br>
												  <i>"Hello #{self.name}, my name is #{operator.name} representing Halo Monitoring, Inc. We have detected a #{event.event_type} by  #{self.name}. Would you like us to dispatch an ambulance?"
												  </i>
												  eos
		return info
  end
  def format_phone(number)
    number.blank? ? "N/A" : number.strip 
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
    name + "\t  : Home #{format_phone(profile.home_phone)} | Cell #{format_phone(profile.cell_phone)} | Work #{format_phone(profile.work_phone)}"  
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
    if(self.is_new_caregiver)
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

