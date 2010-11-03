class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :coupon_codes, :class_name => "DeviceModelPrice" # , :foreign_key => "group_id"
  has_many :dial_ups # WARNING: Code cover required : https://redmine.corp.halomonitor.com/issues/2809
  has_many :emergency_numbers
  has_many :orders
  has_many :recurring_charges
  has_many :rmas
  has_many :rma_items
  has_many :roles, :as => :authorizable
  has_many :triage_thresholds
  has_many :user_intakes
  # named_scope :distinct_by_name, :select => "DISTINCT name, *", :order => "name ASC"

  validates_presence_of :name
  # FIXME: validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[a-z0-9_]+\z/, :message => 'Only lowercase and numeric characters are allowed'
  # http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html#method-i-validates_format_of
  # email validation taken from rails api
  # check email validity for master group. others exempted
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :is_master_group?

  # Tue Nov  2 06:35:33 IST 2010
  #   no need of this. user [user.is_admin_of_what, user.is_sales_of_what].flatten.uniq
  # # groups where user has "sales" or "admin" role
  # # Usage:
  # #   Group.for_sales_or_admin_user( User.first)
  # named_scope :for_sales_or_admin_user, lambda { |user| 
  #   group_ids = user.group_memberships.collect {|group| (user.is_sales_of?(group) || user.is_admin_of?(group)) ? group.id : nil }.compact
  #   { :conditions => {:id => group_ids} }
  # }
  
  named_scope :ordered, lambda {|*args| {:order => (args.flatten.first || :name)}}

  # --------------- triggers / callbacks (never called directly in code)

  # TODO: rspec done. cucumber pending for this
  # at least one value for NORMAL must exist
  def after_create
    options = {
      :status => "normal",
      :battery_percent => 100,
      :hours_without_panic_button_test => 48,
      :hours_without_strap_detected => 48,
      :hours_without_call_center_account => 48
    }
    triage_thresholds.create(options) if triage_thresholds.blank?
  end

  # ==========================
  # = public : class methods =
  # ==========================

  # Usage:
  #   Group.default!
  #   Exclamation sign means this method call is doing anything required to "ensure" results
  def self.default!
    _email = "senior_signup@halomonitoring.com" # default email address
    _group = Group.find_or_create_by_name('default', { :email => _email} ) # find or create default group
    _group.update_attributes( :email => _email) unless _group.email == _email # ensure default email address
    _group # return the default group
  end

  # is this a master group? name should have last 6 characters "master"
  def is_master_group?
    name.to_s =~ /^.._master$/
  end
  
  # find master group of itself
  #   * master group is only available to a group with name pattern ??_(.+) which means 2 letters and '_'
  #   * master group will have a name pattern ??_master where ?? is picked from child group name
  def master_group
    # for example
    #   ml_master for "ml_the_dealer_name"
    #   de_master for "de_ any name suits here"
    #   nothing for bestbuy
    Group.find_by_name( name[0..2] + 'master') if name =~ /^.._(.+)$/
  end

  # Usage:
  #   Group.safety_care!     # will find or create the group and return the active_record
  # Exclamation mark means, this method will do anything required to "ensure" results
  def self.safety_care!
    _email = "safety_care@myhalomonitor.com"
    _group = Group.find_or_create_by_name( 'safety_care', { :email => _email })
    _group.update_attributes( :email => _email) unless _group.email == _email
    _group
  end

  # Usage:
  #   Group.direct_to_consumer
  def self.direct_to_consumer
    find_or_create_by_name('direct_to_consumer', { :email => "direct_to_consumer@myhalomonitor.com"})
  end

  def self.has_default_coupon_codes?
    _devices = [ DeviceModel.myhalo_complete, DeviceModel.myhalo_clip ] # ['complete', 'clip'].collect {|e| DeviceModel.find_complete_or_clip(e) }
    Group.default!.coupon_codes.all( :conditions => { :device_model_id => _devices, :coupon_code => 'default'}).length == 2
  end

  # Usage:
  #   get_coupon_code( :device_model => <AR_object_here>, :coupon_code => '99TRIAL', :part_number => '<here>')
  def coupon( options = {})
    # valid options structure with a coupon code
    if !options.blank? && options.is_a?(Hash) && !options[:coupon_code].blank?
      # AR object given?
      _model = options[:device_model] unless options[:device_model].blank?
      # part_number given? not found yet?
      _model = DeviceModel.find_by_part_number( options[:part_number]) if _model.blank? && !options[:part_number].blank?
      # find amoung counpon_codes for this group
      _coupon = self.coupon_codes.first( :conditions => { :coupon_code => options[:coupon_code], :device_model_id => _model})
    end
    # not found so far? get default for options[:device_model] or myhalo_complete
    _coupon = DeviceModelPrice.default( options[:device_model]) if !defined?(_coupon) || _coupon.blank?
    _coupon
  end

  # QUESTION: how is user.group_memberships different from this?
  #   Tue Nov  2 06:44:15 IST 2010 : updated the logic above now. should be faster
  # groups applicable to user
  # Usage:
  #   Group.for_user( user)
  #   Group.for_user( 'chirag')
  #   Group.for_user( 545)
  def self.for_user( user)
    _user = if user.is_a?( User)
      user
    elsif user.is_a?( String)
      User.find_by_login( user.strip)
    elsif user.to_i > 0
      User.find_by_id( user.to_i)
    end

    if _user.is_super_admin?
      Group.ordered
    else
      [_user.is_admin_of_what, _user.is_sales_of_what].flatten.uniq.sort {|a,b| a.name <=> b.name }
    end
    # # user.is_a?(User) ? (user.is_super_admin? ? find(:all) : for_sales_or_admin_user(user)) : find(:all)
  end

  # =============================
  # = public : instance methods =
  # =============================

  ["reseller", "retailer", "call_center"].each do |_what|
    define_method "is_#{_what}?".to_sym do
      sales_type == _what
    end
  end

  # def users
  #   # all users having any role for this group
  #   # Usage:
  #   #   group.users
  #   users_of_roles(roles)
  # end
  
  # ids of all users that have any role in this group
  def user_ids
    users.collect(&:id).flatten.compact.uniq
  end

  def users_with_role(role = nil)
    # all users having specific role in the group
    # Usage:
    #   group.users_with_role("admin")
    #   group.users_with_role(["admin", "sales"])
    users_of_roles(roles(:conditions => {:name => role}))
  end
  
  def admins
    self.has_admins # use authorization gem
    #  Thu Nov  4 00:03:19 IST 2010, ramonrails 
    #   Old logic 
    # users_with_role( "admin")
  end

  # ===================
  # = private methods =
  # ===================

  private

  def users_of_roles(roles)
    roles.blank? ? [] : roles.collect(&:users).flatten.uniq # return an array in all cases
  end

end