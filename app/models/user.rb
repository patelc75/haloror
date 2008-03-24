require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_authorized_user
  acts_as_authorizable
  
  has_many :panics
  has_many :batteries
  has_many :falls  
  has_many :events
  has_many :skin_temps
  has_one  :profile
  has_many :steps
  has_many :vitals
  belongs_to :role
  has_one :roles_user
  has_one :roles_users_option
  
  has_many :devices
  
  #has_many :call_orders, :order => :position
  #has_many :caregivers, :through => :call_orders #self referential many to many

  # Virtual attribute for the unencrypted password
  cattr_accessor :current_user #stored in memory instead of table
  attr_accessor :password

  validates_presence_of     :login, :email
  #validates_presence_of     :serial_number
  
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  #validates_length_of       :serial_number, :is => 10
  
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
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
      if role_user.role.name == 'caregiver'
        patients << User.find(role_user.role.authorizable_id)
      end
    end
    
    patients
  end

  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    crypted_password.blank? || !password.blank?
  end
    
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end 
end

class Caregiver < User
	
end