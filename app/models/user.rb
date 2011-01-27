require 'digest/sha1'

class User < ActiveRecord::Base
  include UtilityHelper

  # =============
  # = constants =
  # =============
  
  # IMPORTANT -----------------
  #   * The order of appearance of the keys, MUST be exactly as shown from pending .. installed
  #   * shift_to_next_status method depends on this
  STATUS = {
    :pending          => "",
    :approval_pending => "Ready for Approval",
    :install_pending  => "Ready to Install",
    :bill_pending     => "Ready to Bill",
    :installed        => "Installed",
    :overdue          => "Install Overdue",
    :cancelled        => "Cancelled"
  }

  STATUS_IMAGE = {
    :pending          => "user.png",  
    :approval_pending => "user.png",  
    :install_pending  => "user.png",  
    :bill_pending     => "user.png",  
    :installed        => "user.png",
    :overdue          => "user.png",  
    :cancelled        => "user.png",  
  }
  STATUS_BUTTON_TEXT = {
    :pending          => "Submit",
    :approval_pending => "Approve",
    :install_pending  => "Re-Submit", # Install is not an action until panic test data is received
    :bill_pending     => "Bill",
    :installed        => "Installed",
    :overdue          => "Re-Submit", # Install is not an action until panic test data is received
    :cancelled        => "Submit"
  }

  # Fri Oct  1 22:56:06 IST 2010
  # https://redmine.corp.halomonitor.com/projects/haloror/wiki/Intake_Install_and_Billing#Other-notes
  # https://redmine.corp.halomonitor.com/issues/3274
  # https://redmine.corp.halomonitor.com/issues/398
  #   aggregated_status of the user is calculated as
  #   * Installed = user.status == "Installed"
  #                 Legacy halousers will be assigned "installed" state if user is halouser of safety_care
  #                 All other halousers, demo boolean is set to true
  #   * Pending   = user.status == "Not Submitted" or "Ready for Approval" or "Ready for Install" or "Ready to Bill"
  #   * Demo      = user.demo_mode == true
  #   * Cancelled = user.status == "Cancelled"
  AGGREGATE_STATUS = {
    :installed    =>  "Installed",
    :pending      =>  "Pending",
    :demo         =>  "Demo",
    :cancelled    =>  "Cancelled"
  }
  
  # Usage:
  #   <%= User::TRIAGE_ALERT[which] || which.split('_').collect(&:capitalize).join(' ') %>
  #   Custom labels/description for triage alert types
  #   When not defined here, the sample logic above will generate capitalized text from alert_type
  TRIAGE_ALERT = {
    "panic" => "Panic Button Test",
    "dial_up_alert" => "800 Abuse Alert"
  }
  
  # ==========================
  # = includes and libraries =
  # ==========================
  
  acts_as_authorized_user
  acts_as_authorizable
  acts_as_audited :except => [:is_caregiver, :is_new_caregiver]
  
  #composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  
  # ================================
  # = attributes and accessibility =
  # ================================
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation
  attr_accessible :need_validation
  attr_accessor :need_validation
  attr_accessor :is_keyholder, :phone_active, :email_active, :text_active, :active, :need_validation
  attr_accessor :caregiver_position, :lazy_roles, :lazy_options, :lazy_associations
  # Virtual attribute for the unencrypted password
  cattr_accessor :current_user #stored in memory instead of table
  attr_accessor :password
  attr_accessor :current_password,:username_confirmation

  # arranged associations alphabetically for easier traversing
  
  # =============
  # = relations =
  # =============
  
  belongs_to :creator, :class_name => 'User',:foreign_key => 'created_by'
  belongs_to :last_battery, :class_name => "Battery", :foreign_key => "last_battery_id"
  belongs_to :last_event, :class_name => "Event", :foreign_key => "last_event_id"
  belongs_to :last_panic, :class_name => "Panic", :foreign_key => "last_panic_id"
  belongs_to :last_strap_fastened, :class_name => "StrapFastened", :foreign_key => "last_strap_fastened_id"
  belongs_to :last_triage_audit_log, :class_name => "TriageAuditLog", :foreign_key => "last_triage_audit_log_id"
  belongs_to :last_vital, :class_name => "Vital", :foreign_key => "last_vital_id"
  
  has_one  :profile, :dependent => :destroy # , :autosave => true
  has_one  :invoice, :dependent => :destroy
  
  has_many :access_logs
  has_many :batteries
  has_many :blood_pressure
  has_many :dial_ups
  has_many :events
  has_many :event_actions
  has_many :falls  
  has_many :halo_debug_msgs
  has_many :logs, :class_name => "UserLog", :foreign_key => "user_id"
  has_many :mgmt_cmds
  has_many :notes
  has_many :orders_created, :class_name => 'Order', :foreign_key => 'created_by'
  has_many :orders_updated, :class_name => 'Order', :foreign_key => 'updated_by'
  has_many :panics
  has_many :purged_logs
  has_many :rmas
  has_many :rma_items
  has_many :roles_users, :dependent => :delete_all # # WARNING: do not touch this association
  has_many :roles, :through => :roles_users # WARNING: do not touch this association
  has_many :self_test_sessions
  has_many :skin_temps
  has_many :steps
  has_many :subscriptions, :foreign_key => "senior_user_id"
  has_many :triage_audit_logs
  has_many :triage_audit_logs_created, :class_name => "TriageAuditLog", :foreign_key => "created_by"
  has_many :triage_audit_logs_updated, :class_name => "TriageAuditLog", :foreign_key => "updated_by"
  has_many :vitals
  has_many :weight_scales
  
  has_and_belongs_to_many :devices
  has_and_belongs_to_many :user_intakes # replaced with has_many :through on Senior, Subscriber, Caregiver
  
  #has_many :call_orders, :order => :position
  #has_many :caregivers, :through => :call_orders #self referential many to many
  
  # ===============
  # = validations =
  # ===============
  
  # validate associations
  # validates_associated :profile, :unless => "skip_validation" # Proc.new {|e| skip_validation }
  #validates_length_of       :serial_number, :is => 10
  #validates_presence_of     :email
  #validates_presence_of     :serial_number
  validates_confirmation_of :password,                   :if => :password_required?
  validates_format_of       :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'must be valid', :unless => :skip_validation
  validates_length_of       :email,    :within => 3..100, :unless => :skip_validation
  validates_length_of       :login,    :within => 3..40, :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_presence_of     :login, :if => :password_required?
  validates_uniqueness_of   :login, :case_sensitive => false, :if => :login_not_blank?
  
  # before_save :encrypt_password # shifted to a method where we can make multiple calls
  #
  #   Mon Oct  4 19:26:12 IST 2010 v1.6.0
  #   CHANGED: this should be part of before_save, not before_create
  # before_create :make_activation_code # FIXME: this should be part of before_save
  #
  # after_save :post_process # shifted to method instead
  
  # =========================
  # = queries, scopes, .... =
  # =========================
  
  named_scope :all_except_demo, :conditions => { :demo_mode => [nil, false] } # https://redmine.corp.halomonitor.com/issues/3274
  named_scope :all_demo, :conditions => { :demo_mode => true } # https://redmine.corp.halomonitor.com/issues/4077
  named_scope :vips, :conditions => ["vip = ?", true] # https://redmine.corp.halomonitor.com/issues/3894
  # 
  #  Tue Jan  4 22:56:00 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3961
  #   * the search is now case-insensitive. User can search in any "text-case"
  named_scope :filtered, lambda {|arg| query = "%#{arg}%".upcase; { :include => :profile, :conditions => ["users.id = ? OR upper(users.login) LIKE ? OR upper(profiles.first_name) LIKE ? OR upper(profiles.last_name) LIKE ?", arg.to_i, query, query, query]}}
  named_scope :where_status, lambda {|arg| { :conditions => { :status => arg } }}
  named_scope :where_id, lambda {|*arg| { :conditions => { :id => arg.first} }}
  named_scope :ordered, lambda {|*args| { :include => :profile, :order => ( args.flatten.first || "id ASC" ) }} # Wed Oct 13 02:52:36 IST 2010 ramonrails

  # ===============================
  # = triggers, events, callbacks =
  # ===============================
  
  def after_initialize
    self.caregiver_position ||= {}
    # #
    # # assume not in demo mode
    # self.demo_mode = false if new_record? && demo_mode.nil?
    # self.vip = false if new_record? && vip.nil?
    #
    # just make the login blank in memory, if this is _AUTO_xxx login
    self.login = "" if (login =~ /_AUTO_/)
    #
    # default: assume we need a validation
    # features like user intake that do not want validation can switch it off
    self.need_validation = true
    # #
    # # instantiate a profile object if not already
    # self.build_profile if profile.blank?
    # example:
    #   user.roles = {:halouser => @group}
    #   user.roles[:subscriber] = @senior
    self.lazy_roles = {} # lazy loading roles of this user
    self.lazy_options = {} # lazy loading options of this user, if this is a caregiver
    self.lazy_associations = {} # user intake and other associations that user should have when saved
  end

  def before_save
    #
    # Mon Oct  4 19:27:23 IST 2010, v1.6.0
    # activation code should be created for .create as well as .save
    make_activation_code # generate activation code as appropriate
    autofill_login # pre-fill login and password with _AUTO_xxx login, unless already
    #
    encrypt_password
    # https://redmine.corp.halomonitor.com/issues/3215
    # WARNING: we need to confirm which logic holds true to shift user to "Installed" mode
    #   * when alert_status == "normal"
    #   * when panic button test happens in "Ready to Install" state
    #
    # # https://redmine.corp.halomonitor.com/issues/398
    # # When user is created, put in "Install" state by default
    # # User goes from "Install" to "Active" state after all the installation special status fields go green
    # status = (self.alert_status == 'normal' ? STATUS[:active] : STATUS[:installed])

    # status column is about to change
    if self.changed?
      #
      add_triage_audit_log # create a log at least
      #
      # more actions for changes made to status
      if !self.status_change.blank?
        #
        # Send an email to administrator if
        #   * status column is about to change to "Installed" just now
        if self.status_change.last == User::STATUS[:installed]
          # 
          #  Thu Jan 27 00:51:51 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4088
          self.installed_at = Time.now # mark the timestamo when status changed to 'Installed'
          UserMailer.deliver_user_installation_alert( self)
        end
        #
        # do not update the status_changed_at timestamp if that itself is updated during the change
        self.status_changed_at = Time.now if self.status_changed_at_change.blank?
      end
    end
  end

  # https://redmine.corp.halomonitor.com/issues/398
  # Create a log page of all steps above with timestamps
  def after_save
    #
    # Wed Oct 13 04:05:20 IST 2010
    #   CHANGED: created_at == updated_at only when it is saved for the very first time
    # if (created_at == updated_at)
      #
      # CHANGED: Major fix. the roles were not getting populated
      # insert the roles for user. these roles are propogated from user intake
      # 
      #  Thu Dec  9 01:59:43 IST 2010, ramonrails
      #   * FIXME: DRY this conditional block
      lazy_roles.each do |k,v|
        unless v.blank?
          if k == :caregiver
            self.send( "is_#{k}_of", v) unless self.equal?( v)
          else
            self.send( "is_#{k}_of", v)
          end
        end
      end
      #
      # caregiver options
      lazy_options.each do |k,v|
        #   * DRYed: Tue Dec 21 00:52:57 IST 2010
        #   * blank or not_saved means not_valid
        unless k.blank? || k.new_record?
          #   * save role_options
          self.options_for_senior( k, v) # will also create alert_options for critical alert types
        end
      end
      # 
      #  Thu Jan 13 02:31:10 IST 2011, ramonrails
      #   * lazy_associations
      lazy_associations.each do |_sym, _ar_row|
        unless _ar_row.blank? || _ar_row.new_record?
          if _sym == :user_intake
            self.user_intakes << _ar_row unless self.user_intakes.include?( _ar_row)
          end
        end
      end
      # 
      #  Fri Nov 12 18:09:50 IST 2010, ramonrails
      #  emails can be dispatched only after roles
      dispatch_emails # send emails as appropriate
    # end
    #
    #   * save the profile after roles are established
    #   * required to increment call center account number HM...
    # 
    #  Thu Dec  9 01:58:50 IST 2010, ramonrails
    #   * FIXME: use :autosave => true
    profile.save unless profile.blank?
    #
    log(status)
  end
  
  # =================
  # = class methods =
  # =================
  
  # shift status column to the next business logical status
  def self.shift_to_next_status( id, message = nil, who_updated = nil)
    # this statement works like this;
    # * fetch status.to_s, therefore converting nil to ''
    # * fetch array of status values STATUS[0..4] which is :pending .. :installed
    # * get the index in the array, for the current status, switch to next
    # * do not change status value when index is not correctly found
    unless ( user = User.find_by_id( id) ).blank?
      user.status = STATUS[ user.next_status_index] # , :updated_by => who_updated
      # status = STATUS[ next_status_index ] unless next_status_index.blank?
      # updated_by = who_updated
      # self.send( :update_without_callbacks) # WARNING: it may not fire certain AR events
      # 
      # logic of the block below is same as above line of statement. just a bit differently written
      #
      # status = case status.to_s # nil will return blank string
      # when STATUS[:pending] ; STATUS[:approval_pending]
      # when STATUS[:approval_pending] ; STATUS[:install_pending]
      # when STATUS[:install_pending] ; STATUS[:installed]
      # end
      #
      # create status row in triage_audit_log
      options = { :status => user.status, :updated_by => who_updated,
        :description => "Status shifted from [#{user.status_was}] to [#{user.status}]" }
      options[:description] += ", trigger: #{message}" unless message.blank?
      
      # test mode is removed when status changes
      user.test_mode = false
      #
      user.save
      user.add_triage_audit_log( options)
    end
  end

  # Fri Oct  1 05:27:06 IST 2010
  #   user.devices.gateways.first works
  #   user.gateway does not? needs investigation
  #
  # Usage:
  #   user.gateway
  #   user.chest_strap
  [:gateway, :chest_strap, :belt_clip, :kit].each do |_device|
    #
    # Fri Sep 24 04:47:01 IST 2010
    # WARNING: we do not stop user from getting more than one gateway
    #
    define_method _device do
      self.devices.send( _device.to_s.pluralize.to_sym).first
    end
  end
  
  def self.halousers
    role_ids = Role.find_all_by_name('halouser', :select => 'id').collect(&:id).compact.uniq
    all( :conditions => { :id => RolesUser.find_all_by_role_id( role_ids).collect(&:user_id).compact.uniq }, :order => "id" )
  end

  # DEPRECATED: use query where_status
  #
  # def self.count_where_status( _status = nil)
  #   where_status( _status).length
  #   # _status = ( _status.blank? ? ['', nil] : _status.to_s.strip )
  #   # count( :conditions => { :status => _status } )
  # end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    (u && u.authenticated?(password)) ? u : nil
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
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
  
  # email = caregiver email
  # seniod_id = senior id
  # return variable = caregiver object
  # 
  #  Sun Dec  5 02:47:56 IST 2010, ramonrails
  #   * TODO: DRY this up. make RESTful
  def self.populate_caregiver(email,senior_id=nil, position = nil,login = nil,profile_hash = nil)#, roles_users_hash = {})
    # 
    #  Sun Dec  5 02:49:26 IST 2010, ramonrails
    #   * when not found, we cannot touch attributes
    #   * we need REST approach, not method oriented code
    @user = User.find_by_login( login) unless login.blank? # check by login first
    @user ||= User.find_by_email( email) unless email.blank? # not found by login, check by email
    @user ||= User.new( :email => email) # not found by email, just instantiate new and assign email
    #   * create activation code
    #   * FIXME: this should be automatically created in before_save event. why here?
    @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    # old code
    #
    # existing_user = User.find_by_email(email)
    # if !login.nil? and login != ""
    #   @user = User.find_by_login(login)
    #   @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    # elsif !existing_user.nil? 
    #   @user = existing_user
    #   @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    # else
    #   @user = User.new
    #   @user.email = email
    # end
    
    if !@user.email.blank?
      # 
      #  Sun Dec  5 02:46:47 IST 2010, ramonrails
      #   * This was skipping the validation of user model earlier
      @user.is_new_caregiver = true
      @user[:is_caregiver] = true
      #  Sun Dec  5 02:47:43 IST 2010, ramonrails
      #   * now we skip validation using this new technique
      @user.skip_validation = true # skip any validation. just save
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
        # 
        #  Sun Dec  5 02:46:00 IST 2010, ramonrails
        #   * FIXME: what is the point of associating a profile with user when @user is not saved after that?
        if profile.valid? && profile.save!
          @user.profile = profile
        end
      end
      senior = User.find(senior_id)

      # if position.blank?
      position ||= senior.next_caregiver_position # self.get_max_caregiver_position(senior)
      # end
      
      role = @user.has_role 'caregiver', senior #if 'caregiver' role already exists, it will return nil
      
      if !role.nil? #if role.nil? then the roles_user does not exist already
        @roles_user = senior.roles_user_by_caregiver(@user)

        self.update_from_position(position, @roles_user.role_id, @user.id)
        #enable_by_default(@roles_user)      
        RolesUsersOption.create(:roles_user_id => @roles_user.id, :position => position, :active => 0)#, :email_active => (roles_users_hash["email_active"] == "1"), :is_keyholder => (roles_users_hash["is_keyholder"] == "1"))
      end
      UserMailer.deliver_caregiver_invitation(@user, senior)
    end
    @user
  end
  
  def self.resend_mail(id,senior)
    @user = User.find(id)
    @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    @user.save
    @senior = User.find(senior)
    UserMailer.deliver_caregiver_invitation(@user, @senior)
  end

  # 
  #  Fri Nov 26 20:31:00 IST 2010, ramonrails
  #   * DEPRECATED: TODO: change all calls to user.next_caregiver_position
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

  # ====================
  # = instance methods =
  # ====================

  # 
  #  Wed Jan 26 23:36:14 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4088
  def important_role
    _roles = roles.collect(&:name).compact.uniq
    ['super_admin', 'admin', 'halouser', 'caregiver'].each { |e| return e if _roles.include?( e) }
  end

  # 
  #  Wed Jan 26 22:49:44 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4088
  def last_vital_timestamp
    last_vital.blank? ? '' : last_vital.created_at
  end

  def force_status!( _status_key = nil)
    if !_status_key.blank? && STATUS.keys.include?( _status_key)
      self.status = STATUS[_status_key]
      self.send( :update_without_callbacks)
    end
  end
  # 
  #  Fri Nov 26 20:38:15 IST 2010, ramonrails
  #   * next caregiver position for "self" senior
  def next_caregiver_position
    #   * we need a position only for halouser reference
    if self.is_halouser?
      #   * fetch all caregivers for this user
      #   * collect thier positions in an array
      #   * eliminate blanks or duplicates (? error!)
      #   * sort them chronologically
      #   * return the number next to the last position
      _last_position = self.has_caregivers.collect { |e| e.caregiver_position_for( self) }.compact.uniq.sort.last
      _last_position ||= 0 # default to zero, or pick the found position
      _last_position + 1 # pick next position
    else
      #   * returning nil can be passed inline into any statement
      #   * an argument received as nil is same as not specified
      nil # "self" is not halouser. what position can we get anyways :)
    end
  end

  # Tue Nov  2 00:57:37 IST 2010
  #   * split the config > users display logic to optimize speed
  #   * only checks next condition if not succeded already
  # FIXME: optimize the view that use this method
  def can_see_config_user?( user = nil)
    _yes = self.is_super_admin?
    _yes = self.is_sales? unless _yes
    _yes = self.is_installer? unless _yes
    #
    # skip considering user conditions if not given
    unless user.blank?
      # special checks for caregivers. they are not members of group
      # FIXME: WARNING: this is very very expensive query!
      _yes = self.is_admin_of_what.collect(&:has_halousers).flatten.uniq.collect(&:has_caregivers).flatten.uniq.include?( user) if user.is_caregiver? && !_yes
      _yes = self.is_admin_of_any?( user.group_memberships) unless _yes
      _yes = self.is_moderator_of_any?( user.group_memberships) unless _yes
    end
    _yes
  end
  
  # default: card processed
  def card_processed?
    #
    # TODO: we should ideally have the credit card information stored with user details, along with order
    #   currently it is saved only in order
    # Business logic:
    #   * user_intakes missing? == card charged
    #   * at least one associated user intake has credit_debit_card_proceessed == true
    #   * billed_monthly? == false
    user_intakes.blank? ? true : (user_intakes.collect(&:credit_debit_card_proceessed).compact.uniq.include?( true) || !billed_monthly?)
  end

  # 
  #  Fri Dec 17 20:48:44 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3891
  #   * Only applies to halouser
  def order_placed_online?
    !( self.is_not_halouser? || user_intakes.blank? || user_intakes.first.order.blank? )
  end

  # 
  #  Fri Dec 17 20:50:55 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3891
  #   * Only applies to halouser
  def subscription_successful?
    order_placed_online? && user_intakes.first.order.subscription_successful?
  end
  
  # 
  #  Wed Nov 17 00:10:26 IST 2010, ramonrails
  #  clones itself along with given/new profile
  def clone_with_profile
    _clone = self.clone # clone itself
    if profile.blank?
      _clone.build_profile
    else
      _clone.profile = profile.clone
    end
    _clone # return the clone
  end
  
  # default: card processed
  # Business logic:
  #   * user_intakes missing? == card charged
  #   * at least one associated user intake has bill_monthly == true
  def billed_monthly?
    user_intakes.blank? ? false : user_intakes.collect(&:bill_monthly).compact.uniq.include?( true)
  end
  
  def need_validation?
    need_validation
  end
  
  def next_status_index
    keys = [ :pending, :approval_pending, :install_pending, :bill_pending, :installed, :test, :overdue]
    values = [ "", "Ready for Approval", "Ready to Install", "Ready to Bill", "Installed", "Test Mode", "Install Overdue"]
    index = ( values.index( status.to_s) || -1 )
    keys[ index + 1]
  end

  # TODO: make this method skip_validation? for more appropriate convention
  def skip_validation
    !need_validation
  end
  
  def validate
    if self.skip_validation
      true
    else
      self.errors.add("user confirmation","does not match with username.") if self.username_confirmation && (self.username_confirmation != self.login)
      self.errors.add( "Profile: ", profile.errors.full_messages.join(', ')) unless profile.blank? || profile.valid?
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
    # instead of checking for all attributes, we will only check the mandatory ones
    #   non-mandatory attributes cannot anyways exist without the mandatory ones
    _options = [:login, :email, :crypted_password,
      :activation_code, :activated_at].collect {|e| self.send(e).blank? }.compact.uniq
    # 
    #  Thu Dec 16 20:57:36 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3880
    #   * profile has to be part of nothing_assigned? check
    #   * user_intakes/new with just the name and no email, when saved was causing blank profile saved
    (_options.length == 1) && !_options.include?( false) && ( profile.blank? || profile.nothing_assigned? )
  end

  def something_assigned?
    !nothing_assigned?
  end

  # profile_attributes hash can be given here to create a related profile
  #
  def profile_attributes=( arg)
    # if !profile.blank? && profile.is_a?( Profile)
    #   # keep the existing user connected. no need to re-assign
    #   self.profile.attributes = attributes # .reject {|k,v| k == "user_id"} # except user_id, take all attributes
    # else
    #   # any_existing_profile = Profile.find_by_user_id(self.id)
    #   # if any_existing_profile
    #   #   self.profile = any_existing_profile
    #   #   self.profile.attributes = attributes
    #   # else
    _attributes = if arg.is_a?( Profile)
      arg.clone.attributes
    elsif arg.is_a?( Hash)
      arg
    else
      {}
    end
    _attributes = _attributes.reject { |k,v| k == 'user_id' }
    self.build_profile if profile.blank?
    _attributes.each { |k,v| self.profile.send( "#{k}=", v) if self.profile.respond_to?( "#{k}=") }
    # (profile.blank? || profile.new_record?) ? self.build_profile( attributes) : self.profile.update_attributes( attributes) # .merge("user_id" => self)
    #   # end
    # end
  end
  
  # # OBSOLETE for now. role options are handled at user_intake
  # # roles_users_option attributes
  # def role_attributes=(attributes)
  #   # create roles_users_option records here
  # end

  # TODO: why do we need this?
  # def before_validation
  #   self.email = "no-email@halomonitoring.com" if self.email == ''
  # end
  
  # fetch position if "this" user assuming he/she is a caregiver to given senior
  # Usage:
  #   * cg.caregiver_position_for( senior) => n
  #   * cg.caregiver_position_for( senior, 2) => 2
  def caregiver_position_for( _senior, _position = nil)
    options_attribute_for_senior(_senior, :position, _position)
  end
  
  # get attribute value from the roles_users_options this user has for senior
  # return blank when not found
  # Usage:
  #   * cg.options_attribute_for_senior( senior, :position) => GET
  #   * cg.options_attribute_for_senior( senior, :position, 2) => SET
  def options_attribute_for_senior( _senior, _attribute, _value = nil)
    #   * fetch options
    if (_options = options_for_senior( _senior))
      #   * check validity of options
      unless ( _options.blank? || !_options.respond_to?("#{_attribute}") )
        if _value.blank?
          _options.send("#{_attribute}")  # GET
        else
          _options.update_attribute( "#{_attribute}", _value) # no callbacks
          _value
        end
      end
    end
  end
  
  # methods for a RESTful approach
  # using the authorization plugin for the following methods
  # examples:
  #   is_halouser?, is_subscriber?, is_caregiver?
  #   is_subscriber_for? senior_user_object
  #   is_caregiver_to? senior_user_object
  #   is_caregiver_to_what => get array if users I am caregiving
  #   has_caregiver => get array of caregivers for me
  # 
  # Thu Nov  4 06:13:47 IST 2010, ramonrails
  # TODO: FIXME: this should handle the roles_users_options directly, without user_intake
  #  Tue Dec 21 23:22:13 IST 2010, ramonrails
  #   * will also create alert_options for critical alert types
  def options_for_senior( _senior, attributes = nil)
    # 
    #  Sat Nov 13 03:37:30 IST 2010, ramonrails
    #  just fetch the options by supplying attributes. blank ones will be handled appropriately
    # if !self.blank? && !_senior.blank?
    #   #   * we cannot store this yet in database
    #   if self.new_record? || _senior.new_record?
    #     if attributes.blank?
    #       #   * return in-memory data
    #       self.caregiver_position[ _senior] if self.caregiver_position.has_key?( _senior)
    #     else
    #       self.caregiver_position[ _senior] = RolesUsersOption.new( attributes)
    #     end
    #   else
    #     self.is_caregiver_of( _senior) unless attributes.blank? # write
    #     role = self.roles.first(:conditions => { :name => "caregiver", :authorizable_id => _senior.id, :authorizable_type => "User" })
    #     options = options_for_role(role, attributes) unless role.blank? # read or write
    #   end
    # end
    #
    # old logic
    #
    if attributes.blank?
      if self.is_caregiver_of?(_senior)
        role = self.roles.first(:conditions => {
          :name => "caregiver", :authorizable_id => _senior.id, :authorizable_type => "User"
        })
        options = options_for_role(role) unless role.blank?
      end
    else
      self.is_caregiver_of(_senior) # FIXME: should it not be already assigned?. do we want to force?
      role = self.roles.first(:conditions => {
        :name => "caregiver", :authorizable_id => _senior.id, :authorizable_type => "User"
      })
      options = self.options_for_role(role, attributes)
    end
    options
  end
  
  # 
  # Thu Nov  4 06:13:47 IST 2010, ramonrails
  # TODO: FIXME: this should handle the roles_users_options directly, without user_intake
  def options_for_role(role, attributes = nil)
    #   * fetch role_id from given instance or id
    #   * no issues, if we cannot identify one
    role_id = if role.is_a?(Role)
      role.id
    elsif role.to_i > 0
      role.to_i
    else
      nil
    end
    #   * proceed only when role_id available, otherwise no point
    #   * role must exist prior to calling this method
    unless role_id.blank?
      #   * get roles_user through ORM
      role_user = roles_users.find_by_role_id( role_id) # RolesUser.first( :conditions => { :user_id => self.id, :role_id => role_id })
      #   * Is this a GET request?
      if attributes.blank?
        # just fetch the options, or return nil
        options = (role_user.blank? ? nil : role_user.roles_users_option)

      # a POST request?
      else
        # create a roles_user unless already exists
        role_user = roles_users.create( :role_id => role_id) if role_user.blank? # RolesUser.create( :user_id => self.id, :role_id => role_id) if role_user.blank?
        # get attributes from the given arguments
        # keep them {} if nothing can be derived
        _attributes = if attributes.is_a?(RolesUsersOption)
          attributes.clone.attributes
        elsif attributes.is_a?( Hash)
          attributes
        else
          {}
        end
        #
        #   * reject IDs from attributes, as they may be blank
        #   * we are building or updating the roles_users_option from roles_users anyways
        _attributes = _attributes.reject {|k,v| k.to_s == 'id' || (k.to_s[-3..-1] == '_id') }
        # fetch or build options
        options ||= (role_user.roles_users_option || role_user.build_roles_users_option)
        # apply attributes to options (all IDs were already rejected)
        _attributes.each { |k,v| options.send("#{k}=".to_sym, v) if options.respond_to?( "#{k}=".to_sym) }
        # persist
        options.save # save it
      end
    end
    options # explicitly return options row
  end

  # when was the device successfully installed for this user
  #   * check when "Installed" status first occured for this user
  #   * and so on...
  # Features:
  #   * no parameters given to search all timestamps
  #   * optionally, one or many , separated keys can be given to fetch specific timestamps
  #   * only returns timestamps that exist, otherwise omit them
  #   * pass :force => true, to include '' for non-existing timestamps
  # Usage:
  #   status_timestamps                         => get timestamps for all statuses
  #   status_timestamps( :installed)            => timestamp when status was changed to "Installed"
  #   status_timestamps( :installed, :pending)  => timestamps when only these statuses happened
  #   status_timestamps( :force)                => force a return value for all keys
  #   status_timestamps( :installed, :force)    => fetch "Installed" timestamp, force return value for all other keys
  # Examples:
  # >> User.find(511).status_timestamps :force
  # => {:test=>"", :installed=>Fri, 06 Aug 2010 17:14:05 UTC 00:00, :pending=>Tue, 22 Jun 2010 21:38:57 UTC 00:00, :overdue=>"", :approval_pending=>"", :install_pending=>"", :bill_pending=>""}
  # >> User.find(511).status_timestamps
  # => {:installed=>Fri, 06 Aug 2010 17:14:05 UTC 00:00, :pending=>Tue, 22 Jun 2010 21:38:57 UTC 00:00}
  def status_timestamps( *options)
    # we need tiemstamps for which keys/attributes
    # * either keys are supplied
    # * or all keys are considered
    # * invalid keys automatically get rejected in this step
    values = []
    keys = ( options.blank? ? STATUS.keys : (STATUS.keys & options) ) # consider all keys, or a subset
    keys = STATUS.keys if keys.blank? # consider all keys if the subset intersection was empty
    unless keys.blank?
      # collect array of arrays. convert to hash before returning
      keys.each do |key|
        if key == :pending
          # [ key, creator.blank? ? created_at.to_s : "#{created_at} by #{creator.name}" ] # when the user row was created
          values += [ key, created_at ] # when the user row was created
        else
          unless last_triage_status.blank?
            # search parameters hash has a different key each time
            # log row is fetched
            #   * first occurance for "Pending for Approval", "Installed" ...
            #   * most recent occurance for "Test Mode", ...
            #   * :pending was handled already before we reached here
            hash = { :conditions => { :user_id => id, :status => User::STATUS[key] }, :order => "created_at ASC" }
            log = TriageAuditLog.send( (STATUS.keys[1..4].include?(key) ? :first : :last), hash) # fetch row from triage audit log
            if options.include?( :force)
              values += [ key, (log.blank? ? '' : log.created_at ) ]
              # [ key, (log.blank? ? '' : (log.creator.blank? ? log.created_at.to_s : "#{log.created_at} by #{log.creator.name}") )]
            else
              values += [ key, log.created_at ] unless log.blank?
              # log.blank? ? nil : [ key, (log.creator.blank? ? log.created_at.to_s : "#{log.created_at} by #{log.creator.name}") ]
            end
          end
        end
      end
      # WARNING: DO NOT COMPACT the array. The elements must be in the form [ [], [], ...]
      # values.to_hash # uses class extension for Array defined in config/initializers/array_extensions.rb
      values.blank? ? {} : Hash[ *values ] # convert to hash
    end
  end
  
  # check last triage_audit_log status (which is updated from user_intake)
  # Uses:
  #   * can help to identify if user is in "read to install" state. allows auto-transition to "installed" using panic test
  def last_triage_status
    last_triage_audit_log.blank? ? '' : last_triage_audit_log.status
  end

  # keep an audit trail in triage_audit_log
  def add_triage_audit_log( args = {})
    # 
    #  Wed Jan  5 23:45:29 IST 2011, ramonrails
    #   * pick up last status from unsaved changes, or fire query
    _last_status = (self.changed? ? status_was : last_triage_status)
    if (status != _last_status)
      options = { :status => _last_status, :is_dismissed => dismissed_from_triage?, :description => "Status updated to [#{status}]. Auto triggered through user model." }
      log = TriageAuditLog.new( options.merge( args).merge( :user => self, :created_by => self.created_by, :updated_by => self.created_by))
      log.send( :create_without_callbacks)
      self.last_triage_audit_log = log # link it, since we do not have callbacks
    end
  end
  
  # # check if dial_up_numbers are have "Ok" status for the given device
  # # * mgmt_cmd row found for device having numbers (identified by cmd_type == dial_up_num_glob_prim)
  # # * all 4 numbers are present
  # # * local numbers cannot begin with "18"
  # def dial_up_numbers_ok_for_device?( device)
  #   unless ( failure = device.blank? ) # cannot check mgmt_cmds without a device
  #     # further logic is based on this mgmt_cmd row
  #     mgmt_cmd ||= mgmt_cmds.first( :conditions => ["device_id = ? AND cmd_type LIKE ?", device.id, "%dial_up_num_glob_prim%"], :order => "timestamp_sent DESC")
  #     unless ( failure = mgmt_cmd.blank? ) # mgmt_cmd row must exist
  #       numbers = (1..4).collect {|e| mgmt_cmd.send(:"param#{e}") } # collect global/local primary/secondary
  #       failure = numbers.any?(&:blank?) unless failure # the set of 4 numbers exist
  #       failure = numbers[0..1].collect {|e| e[0..1] == '18'}.include?( true) unless failure # local numbers (1,2) cannot start with "18"
  #     end
  #   end
  #   !failure
  # end
  
  #  Wed Nov  3 06:11:22 IST 2010, ramonrails 
  #   this is not used anymore 
  #
  # # self.devices must have one with kit_serial_number
  # def device_by_serial_number( serial)
  #   devices.find_by_serial_number( serial.to_s) # unless serial.blank?
  # end
  
  # Sun Oct 24 01:20:01 IST 2010
  #   now accepts an array
  def add_devices_by_serial_number( *_serial)
    unless ( _device_numbers = _serial.flatten.compact - devices.collect(&:serial_number) ).blank? # required - existing = devices to attach
      _device_numbers.each do |_device_serial|
        unless (_device = Device.find_by_serial_number( _device_serial)).blank? # fetch device
          # attach it to the senior, only if
          #   * this device is not attached to anyone
          #   * and of course, we can find this device in database :)
          self.devices << _device if Device.available?( _device.serial_number, self) # future proof? multiple devices?
        end
      end
    end
    #
    # Old logic. DEPRECATED
    #
    # unless device = Device.find_or_create_by_serial_number( serial  )
    #   device = Device.new
    #   device.serial_number = serial_number
    #   # if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
    #   #         device.set_chest_strap_type
    #   #       elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
    #   #         device.set_gateway_type
    #   #       end
    #   device.save!
    # end
    # 
    # if device.device_type.blank?
    #   if(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '1')
    #     device.set_chest_strap_type
    #   elsif(device.serial_number[0].chr == 'H' and device.serial_number[1].chr == '2')
    #     device.set_gateway_type
    #   end   
    # end
    # device.users << user
    # device.save!
  end
  
  # Fri Oct  1 22:56:06 IST 2010
  # https://redmine.corp.halomonitor.com/projects/haloror/wiki/Intake_Install_and_Billing#Other-notes
  # https://redmine.corp.halomonitor.com/issues/3274
  # https://redmine.corp.halomonitor.com/issues/398
  #   aggregated_status of the user is calculated as
  #   * Installed = user.status == "Installed"
  #                 Legacy halousers will be assigned "installed" state if user is halouser of safety_care
  #                 All other halousers, demo boolean is set to true
  #   * Pending   = user.status == "Not Submitted" or "Ready for Approval" or "Ready for Install" or "Ready to Bill"
  #   * Demo      = user.demo_mode == true
  #   * Cancelled = status == "Cancelled"
  def aggregated_status
    if demo_mode?
      AGGREGATE_STATUS[ :demo]
    else
      #
      # legacy?
      # if user_intakes.blank? # legacy?
      #   AGGREGATE_STATUS[ (self.is_halouser_of?( Group.safety_care!) ? :installed : :demo) ]
      #   
      # else # user_intake? not legacy
        if status == STATUS[ :installed]
          AGGREGATE_STATUS[ :installed]
          #
          # pending, ready for approval / install / bill, install overdue
        elsif [:pending, :approval_pending, :install_pending, :bill_pending, :overdue].collect {|e| STATUS[e]}.include?( status)
          AGGREGATE_STATUS[ :pending]

          # Sat Oct  2 23:17:10 IST 2010 Discussed with Chirag
          # Cancelled show as one of the aggregate status
          # test mode is ignored for aggregate status
        elsif status == STATUS[ :cancelled]
          AGGREGATE_STATUS[ :cancelled]
        end

      # end # not legacy?
    end # demo?
  end #--

  def status_index
    STATUS.index( status) || :pending # use status value to find key, or assume :pending
  end
  
  def status_button_text
    STATUS_BUTTON_TEXT[ STATUS[status_index].blank? ? :pending : STATUS[status_index] ]
  end
  
  def submit_button_text
    (status == STATUS[:approval_pending]) ? STATUS_BUTTON_TEXT[status_index] : "#{status.blank? ? 'Submit' : STATUS_BUTTON_TEXT[status_index] }"
  end
  
  def status_button_color
    colors = { 'abnormal' => 'red', 'caution' => 'yellow'}
    _status = alert_status # (status == STATUS[:installed] ? 'installed' : alert_status)
    #
    # # only for "Installed" status, special "green" color is applied
    # # everything else works as per business logic
    # status == 'Installed' ? 'green' : (colors.keys.include?( _status) ? colors[ _status] : 'gray')
    colors.keys.include?( _status) ? colors[ _status] : 'gray'
    # case _status
    # # when 'installed'; 'green'
    # when 'abnormal' ; 'red'
    # when 'caution'  ; 'yellow'
    # else              'gray';
    # end
    #
    # CHANGED: Old method of selecting color. Does not fit for date-relative status colors
    #   The valid logic now: Call "alert_status" to check status and color based on that
    # STATUS_COLOR[ status_index]
  end

  # 
  #  Thu Dec 23 20:43:19 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3913
  #   * replaces '' with 'Not Submitted'. All other status, as they are
  def status_text
    status || 'Not Submitted'
  end
  
  def status_image
    STATUS_IMAGE[ status_index]
  end
  
  # Create a log page of all steps above with timestamps
  def log(message = "")
    logs.create( :log => message) unless message.blank?
  end
  
  def last_log_when_status_changed
    # pick the log from ascending order, when status was changed
    logs.first( :conditions => { :log => status }, :order => "created_at") # this was DESC
  end

  # for the business logic, we only need to check 1 and 7 days
  # no need to fetch all data and get entire details
  def days_since_status_changed
    status_changed_at.blank? ? 30 : ((Time.now - status_changed_at) / 1.day).round
    # span = 0
    # check_days = [1, 7]
    # check_days.each do |n|
    #   if span.zero?
    #     logs = triage_audit_logs.all( :conditions => ["created_at <= ?", n.days.ago], :select => "status")
    #     if (logs.collect(&:status).uniq.compact.length > 1)
    #       span = n
    #     end
    #   end
    # end
    # #
    # # Assumption: status changed earlier than the longest span we want to check
    # #   so the change is very old for any recent business logic
    # span.zero? ? (check_days[-1] + 1) : span # the oldest point beyond which we do not bother
  end

  def triage_users(options = {})
    day = options[:search_day].to_i
    hour = options[:search_hour].to_i
    minute = options[:search_minute].to_i
    battery_percent = options[:search_battery_percent].to_i
    groups = groups_where_admin # where this user is admin
    group = Group.find_by_id(options[:search_group].to_i) || Group.find_by_name(options[:search_group]) if options[:search_group]
    group ||= groups.first
    users = group.users
    users = users.select {|user| user.updated_at >= (Time.now - day.days - hour.hours - minute.minutes) } unless (day.zero? && hour.zero? && minute.zero?)
    users = users.select {|user| user.battery_percentage <= battery_percent} unless battery_percent.zero?
    users = users.select {|user| (options[:search_status] && options[:search_status] == 'Dismissed') ? user.dismissed_from_triage? : user.not_dismissed_from_triage? }
    users = users.sort {|a,b| a.name <=> b.name }
    return users
  end
  
  def dismiss_batch( what = nil, users = [])
    # when batches are defined with their string names
    case what # take action for each string
      # just dismiss all users in triage. Describe it appropriately in comment
    when "all"
      User.find( users).each {|user| user.dismiss_from_triage( "Dismissed all from triage of #{self.name} at #{Time.now}") }

      # dismissal based on the alert_status
    when "abnormal", "normal", "caution", "test mode"
      User.find( users).each {|user| user.dismiss_from_triage( "Dismissed all #{what} from triage of #{self.name} at #{Time.now}") if user.alert_status == what } unless users.blank?

    # only dismiss selected users
    when "selected"
      User.find( users).each {|user| user.dismiss_from_triage( "Dismissed selected users from triage of #{self.name} at #{Time.now}") } unless users.blank?
      
    else # nothing to dismiss. just refresh the page
      # program control should never reach here
    end
  end
  
  # CHANGED: obsolete now. use "dismiss_batch"
  #
  # def dismiss_all_greens_in_triage
  #   triage_users.each {|user| user.dismiss_from_triage if [50,75,100].include?(user.battery_fill_width) }
  # end
  
  def dismiss_from_triage(message = nil)
    self.last_triage_audit_log = TriageAuditLog.create(:user => self, :is_dismissed => true, :description => (message || "Dismissed at #{Time.now}"), :created_by => self.updated_by, :updated_by => self.updated_by)
  end
  
  # check and return boolean, if this user was in triage list and was dismissed today
  def dismissed_from_triage?
    last_log = last_triage_audit_log # cace column in table
    (!last_log.blank? && !last_log.created_at.blank?) ? ((last_log.created_at.to_date == Date.today) && last_log.is_dismissed) : false
  end
  
  def not_dismissed_from_triage?
    !dismissed_from_triage?
  end

  # TODO: rspec pending for this
  def hours_since(what = nil, options = {})
    # return blank here to default hours_since == 0
    time = case what
    # panic button span is counted
    #   * no panic button tested yet? count hours since installation date
    #   * panic button was tested at least once? count hours since last panic button
    when :panic
      last_panic.blank? ? created_at : last_panic.timestamp

    # strap fastened is counted
    #   * only for 'Chest Strap' users. returning blank for non-chest-strap-users will make status normal
    #   * every span/24hrs after installation date
    when :strap_fastened
      (last_strap_fastened.blank? ? created_at : last_strap_fastened.timestamp) if (get_wearable_type == 'Chest Strap')

    # when profile or call center account missing, hours are counted since 48.hours.before.installation
    when :call_center_account
      call_center_account.blank? ? (created_at - 48.hours) : Time.now

    # test mode is always abnormal status
    when :test_mode
      1.year.ago # force abnormal
      
    when :software_version
      devices_software_up_to_date? ? Time.now : 1.year.ago
      
    when :dial_up_status
      # WARNING: Assume Ok, unless it fails
      (gateway && gateway.last_dial_up_failed?) ? gateway.last_dial_up_status.created_at : Time.now
      
    when :dial_up_alert
      (gateway && gateway.dial_up_alert_pending?) ? gateway.last_dial_up_alert.created_at : Time.now
      
    when :mgmt_query_delay
      # when gateway exists, pick up the timestamp_server of last mgmt query for that gateway
      (gateway && gateway.last_mgmt_query) ? gateway.last_mgmt_query.timestamp_server : Time.now
    end

    time ||= Time.now # default = no time difference (well, almost)
    ((Time.now - time) / 1.hour).round
  end

  # alert status. used in triage
  # fetches triage_thresholds for the group where this user is halouser
  # fetches the "status" from the most appropriately matched triage_threshold
  # TODO: rspec and cucumber pending
  # Usage:
  #   User.last.alert_status_for( :panic)                         # considers all alert types when deciding status
  #   User.last.alert_status_for( :panic, :alert => {"user_intake" => "user_intake"})           # returns "normal". checking for panic, but check allowed only on user_intake
  #   User.last.alert_status_for( :panic, :alert => {"user_intake" => "anything", "panic" => true})   # returns status for panic. checking panic, check allowed also on panic
  def alert_status_for(what = nil, options = {})
    # # check allowed only on these alert types. everything else would return "normal"
    # alerts_to_check = (options[:alert].blank? ? DEFAULT_ALERT_CHECKS : options[:alert])
    group = self.is_halouser_of_what.flatten.first # fetch the group
    # return 'normal' when group is missing, or, alerts_to_check does not include alert being checked
    # for example: when checking for :panic but :panic not in allowed checks, just return "normal"
    if group.blank? # || !alerts_to_check.include?( what.to_s)
      "normal"
    else
      # returning blank for status will default to 48 hours for abnormal, 24 for caution
      _status = case what
      # check the current delay in hours, find a triage threshold that defines such case, get the status string
      # return blank for status, if threshold missing
      when :panic
        threshold = group.triage_thresholds.first(:conditions => ["hours_without_panic_button_test >= ?", hours_since(:panic)], :order => :hours_without_panic_button_test) unless group.triage_thresholds.blank?
        threshold.status unless threshold.blank?
        
      # fetch status string same as above. Except, it only applies to get_wearable_type 'Chest Strap'
      # TODO: get_wearable_type need to be covered. Not sure if it works correctly as it is.
      when :strap_fastened
        if get_wearable_type == 'Chest Strap' # put if condition on seprate row for faster execution
          _threshold_log = group.triage_thresholds.first(:conditions => ["hours_without_strap_detected >= ?", hours_since(:strap_fastened)], :order => :hours_without_strap_detected)
        end
        _threshold_log.blank? ? 'normal' : _threshold_log.status # consider "normal" if no log created yet

      # hours calculation for call center is positive value? that is abnormal
      when :call_center_account
        (hours_since(:call_center_account) == 0) ? "normal" : "abnormal"

      when :user_intake
        user_intake_submitted_at.blank? ? 'abnormal' : 'normal' # works before or after installation date

      when :legal_agreement
        user_intake_legal_agreement_at.blank? ? 'abnormal' : 'normal' # works before or after installation date

      when :test_mode
        test_mode? ? 'test mode' : 'normal'
        
      when :software_version
        devices_software_up_to_date? ? 'normal' : 'abnormal'
        
      when :dial_up_status
        (gateway && gateway.last_dial_up_failed?) ? 'abnormal' : 'normal'
        
      when :dial_up_alert
        (gateway && gateway.dial_up_alert_pending?) ? 'abnormal' : 'normal'
        
      when :mgmt_query_delay
        statuses = ['normal'] # default
        # search_group is the variable defined in triage views
        group = ( options[:search_group].blank? ? group_memberships.first : Group.find_by_name( options[:search_group]) )
        # pick up defined threshold values for the group, or, just defaults
        unless ( defaults = TriageThreshold.for_group_or_defaults( group) ).blank?
          # picking up these many rows from database will serve every "defaults"
          max_rows = defaults.collect(&:mgmt_query_count).compact.uniq.sort.last # max rows to check
          # search max_rows (applicable to all defaults) from database
          #   faster: check in memory
          if (rows = MgmtQuery.recent_few( max_rows))
            # check each default
            # collect its "status" in array
            defaults.each do |default|
              if rows.select {|e| e.seconds_since_last > default.mgmt_query_delay_span.to_i }.size >= default.mgmt_query_failed_count.to_i
                statuses << default.status
              end
            end
          end
        end
        statuses.flatten.compact.uniq.sort.first # alphabetical order: abnormal, caution, normal

      # UserIntake.installation_datetime
      when :not_submitted
        # when user intake has desired installation date, but user not yet installed
        if !user_intakes.blank? && !user_intakes.first.installation_datetime.blank? && status.blank?
          time_span = ((user_intakes.first.installation_datetime - Time.now) / 1.hour).round.hours
          result = if time_span > 60.hours
            'normal'
          elsif (time_span <= 60.hours) && (time_span > 48.hours)
            'caution'
          else # if (time_span <= 48.hours)
            'abnormal'
          end
        end
        result.blank? ? 'normal' : result

      when :ready_for_approval
        # when user intake has desired installation date, but user not yet installed
        if !user_intakes.blank? && !user_intakes.first.installation_datetime.blank? && (status == STATUS[:approval_pending])
          time_span = ((user_intakes.first.installation_datetime - Time.now) / 1.hour).round.hours
          result = if time_span > 8.hours
            'normal'
          elsif (time_span <= 8.hours) && (time_span > 4.hours)
            'caution'
          else
            'abnormal'
          end
        end
        result.blank? ? 'normal' : result

      when :ready_to_install
        if !user_intakes.blank? && !user_intakes.first.installation_datetime.blank? && (status == STATUS[:install_pending])
          #
          # days after, desired installation date
          time_span1 = if (!user_intakes.first.blank? && !user_intakes.first.installation_datetime.blank?)
            (( user_intakes.first.installation_datetime - Time.now ) / 1.day).abs.round.days
          else
            5.days # force abnormal status
          end
          #
          # days after, ship date + group.grace_mon_days
          time_span2 = if (!user_intakes.first.blank? && !user_intakes.first.shipped_at.blank?)
            (( (user_intakes.first.shipped_at + group.grace_mon_days.to_i.days) - Time.now ) / 1.day).abs.round.days
          else
            5.days # force abnormal status
          end
          # take the higher values
          time_span = ((time_span1 > time_span2) ? time_span1 : time_span2)
          result = if time_span >= 2.days
            'abnormal'
          elsif time_span >= 1.day
            'caution'
          else
            'normal'
          end
        end
        result.blank? ? 'normal' : result

      when :ready_to_bill
        if status == STATUS[:bill_pending]
          span = days_since_status_changed
          if span >= 7
            'abnormal'
          elsif (span >= 1) && (span < 7)
            'caution'
          else
            'normal'
          end
        else
          'normal'
        end

      when :discontinue_service, :discontinue_billing
        if status == STATUS[:installed]
          rma = rmas.first( :order => "created_at DESC")
          dated = ( what == :discontinue_service ? rma.discontinue_service_on : rma.discontinue_bill_on ) unless rma.blank?
          unless dated.blank?
            if dated == Date.yesterday
              'abnormal'
            elsif dated == Date.tomorrow
              'caution'
            else
              'normal'
            end
          end
        else
          'normal'
        end

      else
        'normal' # anything that does not fit above, must count as normal
      end
      
      # when threshold is not defined. the following hard coded logic will work
      #   48 hours or more delayed = abnormal
      #   24 hours, up to 48 hours delayed = caution
      #   less than 24 hours delayed = normal
      # when threshold defined
      #   threshold data defines the logic
      _status.blank? ? (hours_since(what) >= 48 ? "abnormal" : (hours_since(what) >= 24 ? "caution" : "normal")) : _status
    end
  end
  
  # combined alert status
  # alert status for panic, strap_fastened, call_center_account are collected
  # most severe status returned
  # TODO: rspec and cucumber pending. cache this? check while performance tuning
  # Usage:
  #   User.last.alert_status( :alert => {:panic => :panic, :user_intake => :user_intake})   # only check these 2 alerts to decide status. otherwise consider "normal"
  def alert_status( options = {})
    # collect status for all events in an array
    # insert 'normal' to include at least one default
    # either pick 'test mode' , or just pick the first alphabetic one. incidentally the required order is albhabetic
    #
    # test_mode? is no more a special color. Color is always subject to other properties
    #
    # if test_mode? # ( (options.blank?) || (options && options.include?( User::STATUS[:test] )) || (options && options[:alert] && options[:alert].include?( User::STATUS[:test] )) ) &&
    #   # when checking for test mode and that check is allowed to decide status
    #   'test mode' # this is not same as User::STATUS
    #
    # if installed?
    #   'installed'
    #   
    # else
      # include "options" while checking the status for each alert type
      #   this will check the actual status only for allowed alert types
      #   everything else is considered "normal" since want to ignore that status
      # Tue Oct 26 22:17:53 IST 2010
      #   refer to bus_user_intake_states.feature:30 for taking out user_intake from array here
      # FIXME: DRY: optimize this to run unless highest severity is registered
      #   ignore further checks if "abnormal" state is received anywhere
      values = [ :panic, :strap_fastened, :call_center_account, :legal_agreement, # , :user_intake
        :test_mode, :software_version, :dial_up_status, :dial_up_alert, :mgmt_query_delay,
        :not_submitted, :ready_for_approval, :discontinue_billing, :discontinue_service,
        :ready_to_bill, :ready_to_install
        ].collect {|e| alert_status_for(e, options) }.insert(0, 'normal')
      values.compact.uniq.sort.first
    # end
  end
  
  def installed?
    status == STATUS[:installed]
  end
  
  # call center account number from profile
  def call_center_account
    profile.blank? ? '' : profile.account_number
  end

  # use TriageThreshold table to search warning status
  def warning_status_threshold
    threshold = TriageThreshold.for_group_or_defaults( self.is_halouser_of_what.first ).select {|e| e.status.downcase == "warning" }
    threshold = TriageThreshold.new( :status => "warning", :attribute_warning_hours => 48, :approval_warning_hours => 4) if threshold.blank? # default status, if one not found in definitions
  end
  
  # warning status is based on threshold definition for it
  # 
  def warning_status?
    threshold = warning_status_threshold # we can buffer this method instead of this variable, but that becomes less maintainable
    # warning flagged if
    #   * threshold not defined for "warning"
    #   * all attribute statuses are good. except cell_center_account, dial_up_numbers
    #   * test mode is also ignored since we are checking all attributes anyways
    #   * time elapsed more than the attribute-threshold defined for "warning"
    #   * workday or off days are all the same here
    warning = (threshold && attributes_status_good?( :omit => [:call_center_account, :sc_account_created_on, :dial_up_numbers]) && ((Time.now - user_intakes.first.installation_datetime) / 1.hour).round > threshold.attribute_warning_hours)
    # warning flagged if
    #   * threshold not defined for warning
    #   * user.status.blank means not approved. First action one can take is, approval. pending status is blank
    #   * time elapsed more than the threshold "business hours" defined for approval status
    #   * appropriately considers weekend, late night installations as well as weekends, while calculating workdays
    warning = ( threshold && status.blank? && ( Time.now > business_hours_later( threshold.approval_warning_hours )) ) unless warning
  end

  # https://redmine.corp.halomonitor.com/issues/3213
  # identify if any columns in the list view are "red"
  def attributes_status_good?( options = {})
    # test mode does not prevent any checking. we check anyways
    #
    failure = user_intakes.blank?
    #
    # check all these attributes, but save some processor time with condition within block
    [ :installation_datetime, :created_by, :credit_debit_card_proceessed, :bill_monthly,
      :legal_agreement_at, :paper_copy_submitted_on, :senior, :sc_account_created_on,
      :created_at, :updated_at ].each {|e| failure = user_intakes.first.send(e).blank? unless failure }
    #
    # check some methods too
    [ :chest_strap, :belt_clip, :gateway, :call_center_account].each {|e| failure = self.send(e).blank? unless failure }
    #
    # call_center_account can be omitted. so we check it separately
    failure = self.call_center_account.blank? unless failure || (options[:omit] && options[:omit].include?( :call_center_account))
    #
    # dial_up_numbers should also be ok
    # omit checking this, if so requested
    failure = !gateway.dial_up_numbers_ok? unless failure || (options[:omit] && options[:omit].include?( :dial_up_numbers)) # do not bother if already failed
    # failure = !dial_up_numbers_ok_for_device?( device_by_serial_number( user_intakes.first.kit_serial_number)) unless failure || (options[:omit] && options[:omit].include?( :dial_up_numbers)) # do not bother if already failed
    !failure
  end

  def desired_installation_date
    _intake = user_intakes.first
    _intake.blank? ? nil : (_intake.installation_datetime || _intake.created_at)
  end
  
  def user_intake_submitted_at
    user_intakes.first.blank? ? '' : user_intakes.first.submitted_at
  end
  
  def user_intake_legal_agreement_at
    user_intakes.first.blank? ? '' : user_intakes.first.legal_agreement_at
  end
  
  def devices_software_up_to_date?
    # all devices of this user have current firmware software version?
    #   no alert if everything up-to-date
    #   alert when software version does not match
    devices.reject(&:current_software_version?).blank?
  end
  
  # 
  #  Tue Nov 23 22:19:53 IST 2010, ramonrails
  #   * Whether activation email was sent
  def activation_email_sent?
    !activation_sent_at.blank?
  end
  
  # https://redmine.corp.halomonitor.com/issues/3067
  # email must be dispatched by explicit calls now
  # 
  #  Tue Nov 23 20:58:22 IST 2010, ramonrails
  #   * emails are only dispatched on submit, not save
  #   * identify submit as skip_vaiation == false
  #  Fri Dec 10 21:04:05 IST 2010, ramonrails
  #   * added "_forced" option for "resend" action
  #
  def dispatch_emails( _forced = false)
    unless email.blank? # cannot send without valid email
      #  Fri Dec 10 21:04:14 IST 2010, ramonrails
      #   * "resend" needs _forced
      unless activation_email_sent? || activated? || _forced
        # 
        #  Tue Nov 23 22:21:44 IST 2010, ramonrails
        #   * https://spreadsheets0.google.com/ccc?key=tCpmolOCVZKNceh1WmnrjMg&hl=en#gid=4
        #   * signup_installation email is deprecated now
        #   * Only 2 type of emails are dispatched for activation
        #
        # if self.is_halouser? # WARNING: DEPRECATED user[:is_new_halouser] == true
        #   # Mon Nov  1 22:29:21 IST 2010
        #   # QUESTION: Should this go out only during certain "states"?
        #   UserMailer.deliver_signup_installation( self, self) unless self.activated? # || self.user_intakes.first.just_submitted?
        #   
        # else # user type?
        # 
        #  Tue Nov 23 18:54:13 IST 2010, ramonrails
        #   * Invitation to be a caregiver
        #   * https://redmine.corp.halomonitor.com/issues/3767
        #
        # #  Tue Nov 23 22:29:50 IST 2010, ramonrails
        # # No emails should be dispatched on "Save", only "Submit" of user intake.
        # # QUESTION: too complicated to implement like this. Needs discussion
        #   * when admin is created, it is "saved", not "submitted"
        #   * order "saves" all users instead of "submitting"
        #   * user intake can "save" multiple times before a "submit"
        #
        # _can_send_email = if self.user_intakes.blank?
        #   #   * When no user intake present. legacy data?
        #   #   * Only send when submitted and validated data
        #   #   * user intake "save" button skips the validation
        #   need_validation == true
        # else
        #   #   * either we have a submitted user intake
        #   #   * or we have an associated order (online store)
        #   (user_intakes.first.submitted? || !user_intakes.first.order.blank?)
        # end
        _can_send_email = if self.is_admin?
          #   * admin does not have user_intake
          #   * admin is "saved", not validated
          true
        else
          #   * any non-admin will have user_intake, or order
          ( !user_intakes.blank? && ( user_intakes.first.submitted? || !user_intakes.first.order.blank? ))
        end
        #
        #  Tue Dec 21 00:29:04 IST 2010, ramonrails
        #   * https://redmine.corp.halomonitor.com/issues/3895
        #   * either we have a submitted user intake
        #   * or we have an associated order (online store)
        #   dispatch emails subject to the role
        if _can_send_email
          if self.is_caregiver?
            #   * Only caregiver email will dispatch when subscriber is caregiver
            #   * emails for caregivers
            _recent_senior = is_caregiver_of_what.last
            UserMailer.deliver_caregiver_invitation( self, _recent_senior)
          else
            #   * emails for "non-caregivers". admins, subscribers, halousers and everybody else
            UserMailer.deliver_signup_notification( self)
          end
          #
          #   * Now mark the dispatch of email, for next time
          self.update_attribute( :activation_sent_at, Time.now)
        end # can send email
        # end # user type?
      end # activation_email_sent?
      #
      # activation email gets delivered anyways
      UserMailer.deliver_activation(self) if recently_activated?
    end # cannot send without valid email
    #
    #  Tue Dec 21 00:33:39 IST 2010, ramonrails
    #   * return a status whether activation was sent
    return !activation_sent_at.blank? # when this is filled, activation was sent
  end

  def username
    return self.name rescue ""
  end
  
  def owner_user # for auditing
    self
  rescue
    nil
  end

  def connectivity_status_icon
    (last_event && last_event.is_a?(Event)) ? last_event.event.class.name.underscore : 'status_dial_up'
  end

  # color based on calculated fill width on our scale
  def battery_color
    percent = battery_fill_width
    "#{(percent == 10) ? 'red' : ((percent == 25) ? 'yellow' : 'green')}"
  end
  
  # exact battery percentage
  def battery_percentage
    last_battery.blank? ? 100 : last_battery.percentage
  end
  
  # battery fill width in fixed proportions
  # actual percentage is converted to this scale for easy display and calculation
  def battery_fill_width
    percent = battery_percentage
    fill = (([10, 25, 50, 75, 100].select {|e| e <= percent }.last) || 10) # either pick one, or be 10
    fill = ((fill < 10) ? 10 : ((fill > 100) ? 100 : fill))
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

  # #dunamically define profile attributes
  # [:home_phone, :cell_phone].each do |profile_attribute|
  #   define_method profile_attribute do
  #     unless profile.blank?
  #       value = self.profile.send(profile_attribute)
  #     end
  #     value ||= ''
  #   end
  # end
  
  # WARNING: code coverage required
  # Usage:
  #   User.last.gateway       # => returns the "Gateway" device row for this user
  #   User.last.chest_strap   # => returns the "Chest Strap" device row for this user
  #   User.last.belt_clip     # => returns the "Belt Clip" device row for this user
  [:gateway, :chest_strap, :belt_clip].each do |name|
    define_method name do
      # WARNING: AR finder methods cannot work here because "device_type" is a method, not attribute
      #   devices.first( :conditions...) cannot be done here
      devices.select {|e| e.device_type == name.to_s.split('_').collect(&:capitalize).join(' ') }.first
    end
  end
  
  # # CHANGED: use "user.gateway" instead of this method
  # def get_gateway
  #   # WARNING: code coverage required
  #   @gateway_device ||= (devices.select {|e| e.device_type == "Gateway" }.first) # cache
  #   #
  #   # CHANGED: old logic
  #   # gateway = nil
  #   # self.devices.each do |device|
  #   #   if device.device_type == "Gateway"
  #   #     gateway = device
  #   #     break
  #   #   end
  #   # end
  #   # gateway
  # end
  
  # # CHANGED: use "user.chest_strap" instead of this
  # def get_strap
  #   self.devices.each do |device|
  #     if device.device_type == 'Chest Strap'
  #       return device
  #     end
  #   end
  #   return nil
  # end
  
  # # CHANGED: use "user.belt_clip" instead of this
  # def get_belt_clip
  #   self.devices.each do |device|
  #     if device.device_type == 'Belt Clip'
  #       return device
  #     end
  #   end
  #   return nil
  # end
  
  def get_wearable_type
    if bc = self.belt_clip
      bc.device_type
    elsif cs = self.chest_strap
      cs.device_type
    else
      "None"
    end
  end
    
  # Activates the user in the database.
  def activate
    # 
    #  Thu Nov 11 00:54:42 IST 2010, ramonrails
    #  'Save' is mandatory before activating. Cannot just activate a new record in memory
    unless self.new_record?
      @activated = true
      self.activated_at = Time.now.utc
      self.activation_code = nil
      #  Thu Nov 11 00:57:21 IST 2010, ramonrails
      save(false) # WARNING: Risky to skip validations. caused bugs. should work better now
    end
  end
  
  # 
  #  Sun Dec  5 00:06:35 IST 2010, ramonrails
  #   * OBSOLETE: this is not used anymore. check before removing
  # FIXME: need more coverage. some coverage is 
  # roles_users_option should have active flag "on"
  def set_active
    roles_users.each do |ru|
      # update flag for each options-row. create a row if does not exist
      if ru.roles_users_option.blank?
        # 
        #  Fri Nov 12 06:06:34 IST 2010, ramonrails
        #  create new options using the given hash of attributes
        ru.create_roles_users_option( :active => true)
      else
        # 
        #  Fri Nov 12 06:05:50 IST 2010, ramonrails
        #  Updating single attribute
        #  Does not accept a hash. Must be comma separated parameters
        ru.roles_users_option.update_attribute( :active, true)
      end
    end
    #
    # CHANGED: old logic
    # self.roles_users.each do |roles_user|
    #   if roles_user.roles_users_option
    #     roles_user.roles_users_option.active = true
    #     roles_user.roles_users_option.save
    #   end
    # end
  end
  
  def full_name
    profile.blank? ? '' : [profile.first_name, profile.last_name].join(' ')
    # return (self.profile.blank? ? "" : \
    #   ( self.profile.first_name && self.profile.last_name ? \
    #       self.profile.first_name + " " + self.profile.last_name : \
    #       nil
    #   )
    # )
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

  # 
  #  Thu Dec  9 00:15:10 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3850
  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.blank? && !activated_at.blank?
  end
  
  # Returns true if the user has just been activated.
  def recently_activated?
    @activated # this instance variable will exist when user was activated recently.
    # existing record will have data value in table column
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
    # patients = []
    # 
    # RolesUser.find(:all, :conditions => "user_id = #{self.id}").each do |role_user|
    #   if role_user.role and role_user.role.name == 'caregiver' and role_user.roles_users_option and !role_user.roles_users_option.removed
    #     patients << User.find(role_user.role.authorizable_id, :include => [:roles, :roles_users, :access_logs, :profile])
    #   end
    # end
    # 
    # patients
    self.is_caregiver_of_what # will return all seniors for whom this user is a caregiver
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
    self.has_caregivers
  end
  
  def group_admins
    self.user_intakes.collect(&:group).flatten.collect(&:admins).flatten
  end

  # 
  #  Thu Nov  4 06:25:03 IST 2010, ramonrails
  #  * fetch first applicable roles_users_options
  def role_options
    # the user can return multiple IDs here. are we interested in most recent?
    _id = self.is_caregiver_of_what.compact.collect(&:id).compact.sort.last # pick most recent
    _role_id = self.roles.find_by_name_and_authorizable_id( 'caregiver', _id)
    _roles_user = self.is_caregiver? ? self.roles_users.find_by_role_id( _role_id) : nil
    _roles_user.blank? ? nil : _roles_user.roles_users_option
  end
  
  def roles_user_by_role(role)
    self.roles_users.find(:first, :conditions => "role_id = #{role.id}", :include => :role)
  end

  # FIXME: use authorization plugin methods described here, instead of custom methods
  # OBSOLETE: role_options method make this an obsolete now
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
    # new logic
    # * returns all caregivers whether they are positioned or not
    # * adds a sequential integer value as position, if not already
    # * sequential integer value is dereived from Time.now, so it is always at the bottom of the list
    # * index of the enumeration is added to Time.now.to_i to ensure unique sequence
    #
    # https://redmine.corp.halomonitor.com/issues/3047
    #   caregivers are showing up again even after we click the "trash" icon in caregivers list
    #   "trash" icon is removing the position for caregiver and updating "removed" attribute to "true"
    #   so, we need to eliminate "removed" caregivers from this selection
    #
    caregivers.reject {|user| user.options_attribute_for_senior(self, :removed) == true }.enum_with_index.collect {|caregiver, index| [(caregiver.caregiver_position_for(self) || (Time.now.to_i + index)), caregiver] }.sort {|a,b| a[0] <=> b[0] }
    #
    # old logic
    # WARNING: major bug: if caregiver does not have a position yet, it is not included
    # caregivers.each do |caregiver|
    #   if roles_user = roles_user_by_caregiver(caregiver)
    #     if opts = roles_user.roles_users_option
    #       unless opts.removed
    #         cgs[opts.position] = caregiver
    #       end
    #     end
    #   end
    # end
    # cgs = cgs.sort
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
    # https://redmine.corp.halomonitor.com/issues/2967. Super admin role also accounts for admin role.
    self.is_super_admin? ? Group.all(:order => 'name') : (self.is_admin_of_what.compact.select {|element| element.is_a?(Group) }.uniq.sort {|x,y| x.name <=> y.name })
  end
  
  # includes the following groups
  #   * where this use is a member
  #   * where this user is caregiver of a member 
  def extended_group_memberships
    group_memberships + caregiving_group_memberships
  end
  
  # user is_caregiver to halousers.of_these_groups
  def caregiving_group_memberships
    # I am the caregiver, fetch all groups of all senior whom I am caregiving
    # admin of any group in the above list, can edit my profile (caregiver profile)
    self.is_caregiver_of_what.collect(&:group_memberships).flatten
    # if we only want to allow admins of "halouser-group"
    # then change the symbol method to "is_halouser_of_what"
  end
  
  # 
  #  Thu Dec 23 20:11:56 IST 2010, ramonrails
  #   * if super_user? => All groups
  #   * any other user? => groups where the user has "any" role
  #   * ordered => name
  def group_memberships
    # CHANGED: test this
    # Groups for which current_user has roles
    #   ths method is self-contained. does not depend on group_roles
    #   also has additional check for super_admin role
    options = ( is_super_admin? ? {} : \
                {:id => roles.find_all_by_authorizable_type('Group').collect(&:authorizable_id).compact.uniq})
                # self.is_halouser_of_what will not work here. user can have more roles than halouser
    Group.all(:conditions => options, :order => 'name')
    #   group roles of user, uniq, sorted
    #   this method also works but requires "group_roles" method
    # return group_roles.collect {|role| Group.find(role.authorizable_id) }.uniq.sort {|a, b| a <=> b}
    # 
    # if is_super_admin?
    #   groups = Group.all
    # else
    #   roles = group_roles
    #   groups = []
    #   if !roles.blank?
    #     roles.each do |role|
    #       groups << Group.find(role.authorizable_id)
    #     end
    #   end
    #   groups.sort! do |a,b|
    #     a.name <=> b.name
    #   end
    #   groups.uniq!
    # end
    # return groups
  end
  
  def group_memberships_by_role(role)
    # Group.all( :conditions => { :id => group_roles({:name => role}).collect(&:authorizable_id).compact.uniq })
    groups = []
    @role = Role.find_by_name(role)
    groups << Group.find(@role.authorizable_id)
  end
  
  # ramonrails: Fri Oct 15 03:06:51 IST 2010
  #   returns an array of sales_type for all groups this user is member
  def group_sales_types
    self.group_memberships.collect(&:sales_type).compact.uniq # all types of memberships. not just halouser
    #
    # self.is_halouser_for_what.each do |group|
    #   if !group.nil? and group.sales_type != 'call_center'
    #     return group.sales_type
    #   end
    # end
  end
  
  # ramonrails: Fri Oct 15 03:14:33 IST 2010
  # Usage:
  #   user.is_reseller? # checks all group memberships of this user. any reseller group, make this return true
  ["reseller", "retailer", "call_center"].each do |_what|
    define_method "is_#{_what}?".to_sym do
      group_sales_types.include?( _what)
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
  
  def name
    (profile.blank? ? (login.blank? ? email : login) : profile.name)
  end
       
  def id_and_name
     "(#{id}) " + name if !name.nil? 
  end    
  
  # Ticket: 3213 requires this
  # defines the following methods
  #   user.first_name
  #   user.last_name
  [:first_name, :last_name].each do |method_name|
    define_method method_name do
      profile.blank? ? '' : profile.send( method_name)
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
  
  # https://redmine.corp.halomonitor.com/issues/2581
  # FIXME:
  #   these are generic partials that do not require user object. These can be shifted to helpers.
  #   Not shifting these to helpers until we have the code covered with tests (rspec or cucumber)
  def get_call_halo_admin
    markaby do
      div :style => 'font-size: x-large' do
        font :color => 'white' do
          span { "Call Halo Admin in " }
          a :href => '/call_center/faq' do
            'FAQ'
          end
          span { '.' }
        end
      end
    end
      # info = <<-eos 
      #   <div style="font-size: x-large"><font color="white">"Call Halo Admin in <a href="/call_center/faq">FAQ</a>."</div>
      #   eos
      # return info
      #     
  end
  
  # https://redmine.corp.halomonitor.com/issues/2581
  # FIXME:
  #   these are generic partials that do not require user object. These can be shifted to helpers.
  #   Not shifting these to helpers until we have the code covered with tests (rspec or cucumber)
  def get_help_coming_soon
    markaby do
      font :color => 'white' do
        'Recite this script:'
      end
      br
      i do
        div :style => 'font-size: 150%; color: yellow;' do
          "There will be somebody there to help you soon. If we can't reach your caregivers, we will dispatch an ambulance. Goodbye."
        end
      end
    end
      # info = <<-eos 
      #   <font color="white">Recite this script:</font><br>
      #   <i><div style="font-size: 150%; color: yellow;">"There will be somebody there to help you soon. If we can't reach your caregivers, we will dispatch an ambulance. Goodbye."</div></i>
      #   eos
      # return info
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
  
  # FIXME: this is not used anywhere
  # https://redmine.corp.halomonitor.com/issues/2581
  def contact_info_table
    info = <<-eos
      <table><tr><td colspan="2">#{name}</td></tr>
             <tr><td>Home</td><td>#{format_phone(profile.home_phone)}</td></tr>
             <tr><td>Cell</td><td>#{format_phone(profile.cell_phone)}</td></tr>
            <tr><td>Work</td><td>#{format_phone(profile.work_phone)}</td></tr>
      </table>
    eos
    return info
  end
  
  # https://redmine.corp.halomonitor.com/issues/2581
  # This can stay here. It is more specific to user object, than a helper
  def contact_info
    name + ": Home #{format_phone(profile.home_phone)} | Cell #{format_phone(profile.cell_phone)} | Work #{format_phone(profile.work_phone)}"  
  end
  
  # FIXME: this is not used anywhere
  # https://redmine.corp.halomonitor.com/issues/2581
  def phone_numbers
    # this maraby code generates the same output as HTML generated earlier in a hard coded way
    # markaby can be used to make code more DRY
    markaby {
      table {
        ['home', 'cell', 'work'].each do |phone|
          tr {
            td { phone.capitalize }
            td { format_phone(profile.send("#{phone}_phone".to_sym)) }
          }
        end
      }
    }
    # info = <<-eos
    #   <table>
    #          <tr><td>Home</td><td>#{format_phone(profile.home_phone)}</td></tr>
    #          <tr><td>Cell</td><td>#{format_phone(profile.cell_phone)}</td></tr>
    #         <tr><td>Work</td><td>#{format_phone(profile.work_phone)}</td></tr>
    #   </table>
    # eos
    # return info
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
  
  # we need this method because we do not want to get "make_activation_code" public
  def make_activation_pending
    self.make_activation_code # setup an activation code
    # blank out these fields. non-activated user intakes do not have data in any of these fields
    [:activated_at, :login, :crypted_password].each {|field| self.send("#{field}=", nil) }
    self.send(:update_without_callbacks) # just update. no triggers
  end

  def incomplete_user_intakes
    user_intakes.reject(&:submitted?) # user intakes not yet submitted. no submission timestamp found.
  end

  def legal_agreements_pending
    # user intakes that were submitted, but still have an empty flag for legal agreement
    user_intakes.select {|ui| ui.submitted? && ui.legal_agreement_at.blank? }
  end
  
  # TODO: needs some more testing
  #   http://spreadsheets.google.com/a/halomonitoring.com/ccc?key=0AnT533LvuYHydENwbW9sT0NWWktOY2VoMVdtbnJqTWc&hl=en#gid=3
  #   When "Approve" button is hit on user intake
  #   * senior becomes member of safety care
  #   * senior is still in test mode
  #   * caregivers are still away
  def opt_in_call_center
    self.is_halouser_of Group.safety_care!
  end
  
  # https://redmine.corp.halomonitor.com/issues/3016
  # default = stop getting alerts
  #   default action and result is obvious from method name here
  #   pass argument true/false to force specific behavior
  def opt_out_call_center(stop_getting_alerts = true)
    # when opt_out_call_center "off"
    #   * make the user halouser of safety_care
    #   * all alerts will be delivered
    # when opt_out_call_center = "on"
    #   * remove haluser membership from safety_care group
    #   * stop getting alerts for events
    # rails_authorization plugin allows the following methods. using them here
    #   is_halouser_of(object)
    #   is_not_halouser_of(object)
    self.send("is_#{stop_getting_alerts ? 'not_' : ''}halouser_of".to_sym, Group.safety_care!)
    log("#{stop_getting_alerts ? 'Opted out of' : 'Added to'} safety_care group") # https://redmine.corp.halomonitor.com/issues/398
  end

  def partial_test_mode?
    self.is_halouser_of?( Group.safety_care!) # other parameters need not be checked
  end
  
  def test_mode?
    # when user is not part of safety_care
    # and all caregivers are in away mode
    test_mode == true # self.is_not_halouser_of?(Group.safety_care!) && (caregivers.all? {|cg| !cg.active_for?(self) })
  end

  def toggle_test_mode
    set_test_mode!( !test_mode? )
  end
  
  # default action is obvious from method name
  # "!" added to signify the data change and save/update
  def set_test_mode!(status = true)
    #
    # test_mode column
    self.test_mode = (status == true) # just make sure only boolean values are considered
    self.send(:update_without_callbacks) unless self.new_record? # WARNING: This works, but is not best. A better method needs to be here
    # user test mode
    #   * user is not part of safety_care
    #   * has all caregivers "away"
    # self.send("is_#{(status == true) ? 'not_' : ''}halouser_of".to_sym, Group.safety_care!)
    opt_out_call_center(status) # will also log
    # when switching user to "normal" mode
    # * just make it member of safety_care
    # * do not bother switching "active" status for caregivers
    # ** maybe, they all were not active when user was switched to "test mode"
    self.caregivers.each {|cg| cg.set_away_for(self) } if status == true # will log at set_away_for, set_active_for
  end
  
  def demo_mode?
    demo_mode == true
  end 
  
  def vip?
    vip == true
  end
  
  def toggle_demo_mode
    set_demo_mode( !demo_mode)
  end
  
  def toggle_vip
    set_vip(!vip) 
  end     
  
  def set_vip_mode( status = false)
    self.vip = ( status == true)
    self.send( :update_without_callbacks) unless self.new_record?
  end
  
  def set_demo_mode( status = false)
    self.demo_mode = ( status == true)
    self.send( :update_without_callbacks) unless self.new_record?
  end
  
  # Usage:
  #   user.caregivers_active
  #   user.caregivers_away
  ['active', 'away']. each do |_what|
    define_method "caregivers_#{_what}".to_sym do
      user_intakes.collect(&"caregivers_#{_what}").flatten.uniq
    end
  end

  def active_for?(user = nil)
    # * is caregiver of user
    # * has roles_users_options data
    # * flagged active
    status = false # default
    if self.is_caregiver_of?(user)
      if (options = self.options_for_senior(user))
        status = options.active
      end
    end
    status
  end
  
  def away_for?( user = nil)
    !active_for?( user)
  end
  
  # set the caregiver away for user
  def set_away_for(user = nil, away = true)
    self.set_active_for(user, !away)
  end
  
  # set the caregiver "active" for halouser
  def set_active_for(_senior = nil, active = true)
    if !_senior.blank? && self.is_caregiver_of?(_senior)
      self.options_for_senior(_senior, {:active => active})
      # https://redmine.corp.halomonitor.com/issues/398
      _senior.log("Caregiver #{name} is #{active ? 'activated' : 'set away'} for user #{_senior.name}")
    end
  end
  
  # cancel account of this user
  #   * this user must be a halouser
  #   * when not halouser, this method has no effect
  # steps taken from https://redmine.corp.halomonitor.com/issues/398
  def cancel_account
    # Send email to SafetyCare similar to the current email to SafetyCare except body will simple oneline with text "Cancel HM1234" 
    CriticalMailer.deliver_cancel_call_center_acct(self.profile.account_number)
    self.log("Email sent to safety_care: Cancel #{self.profile.account_number}")  
    set_test_mode!( true)  # Call Test Mode method to make caregivers away and opt out of SafetyCare    
    # 
    #  Wed Dec 22 20:35:43 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3900
    #   * devices are *not* removed from database
    #   * WARNING: any other user (unlikely in business logic right now) linked to this device will remain linked
    self.devices = []  # release the devices from this user
    #   * "unregister"ing the devices released the devices from all linked user
    #   * for now in business logic, only one user is linked to the device
    # Device.unregister( devices.collect(&:id).flatten.compact.uniq ) # Sends unregister command to both devices 
    caregivers.each {|e| UserMailer.deliver_user_cancelled( self, e) } # Send email to caregivers informing de-activation of device  
    self.status = User::STATUS[:cancelled]
    # 
    #  Thu Dec 30 23:17:56 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3950
    self.cancelled_at = Time.now
    self.send(:update_without_callbacks)
    triage_audit_logs.create( :status => User::STATUS[:cancelled], :description => "MyHalo account of #{name} is now cancelled.") 
  end
  

  # WARNING: This is conflicting with the 1.6.0 Pre-Quality
  #   Order from online store should create a user intake with blank login & password for all associated users
  #   This does not suit well wil existing user intake scenarios
  # Proposed action:
  #   comment out this method to see the affects in cucumber
  #   this can help to idenitfy all the issue quickly
  # WARNING: (Wed Oct  6 05:12:20 IST 2010) Needs code coverage. smoke tested for now
  def autofill_login
    if login.blank? # && !email.blank? # !user.blank? && user.login.blank?
      hex = Digest::MD5.hexdigest((Time.now.to_i+rand(9999999999)).to_s)[0..20]
      # only when user_type is not nil, but login is
      self.login = "_AUTO_#{hex}" # _AUTO_xxx is treated as blank
      self.password = hex
      self.password_confirmation = hex
    end
  end

  # =====================
  # = protected methods =
  # =====================
  
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
    #
    # CHANGED: should this only be for new_record?
    #   does not harm this way either because activated? will ignore any new created activation_code
    #   but this is not error proof
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ) if self.new_record? && activation_code.blank?
  end 
  
  # return true if the login is not blank
  def login_not_blank?
    return (skip_validation ? false : !login.blank?)
  end

  def has_valid_cell_phone_and_carrier?
    profile.blank? ? false : (profile.cell_phone_exists? && !profile.carrier.blank?)
  end
  
  # ===================
  # = private methods =
  # ===================
  
  private

  def skip_associations_validation
    self.profile.skip_validation = skip_validation unless profile.blank?
  end
  
end
