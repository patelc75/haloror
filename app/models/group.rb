class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :coupon_codes, :class_name => "DeviceModelPrice", :foreign_key => "group_id"
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
  # validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[a-z0-9_]+\z/, :message => 'Only lowercase and numeric characters are allowed'
  # http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html#method-i-validates_format_of
  # email validation taken from rails api
  # check email validity for master group. others exempted
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :is_master_group?

  # groups where user has "sales" or "admin" role
  # Usage:
  #   Group.for_sales_or_admin_user( User.first)
  named_scope :for_sales_or_admin_user, lambda { |user| 
    group_ids = user.group_memberships.collect {|group| (user.is_sales_of?(group) || user.is_admin_of?(group)) ? group.id : nil }.compact
    { :conditions => {:id => group_ids} }
  }
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
  #   Group.safety_care     # will find or create the group and return the active_record
  def self.safety_care
    find_or_create_by_name('safety_care', { :email => "safety_care@myhalomonitor.com"})
  end

  # Usage:
  #   Group.direct_to_consumer
  def self.direct_to_consumer
    find_or_create_by_name('direct_to_consumer', { :email => "direct_to_consumer@myhalomonitor.com"})
  end

  # Usage:
  #   Group.default
  def self.default
    find_or_create_by_name('default', { :email => "admin@myhalomonitor.com"})
  end

  def self.has_default_coupon_codes?
    _devices = [ DeviceModel.myhalo_complete, DeviceModel.myhalo_clip ] # ['complete', 'clip'].collect {|e| DeviceModel.find_complete_or_clip(e) }
    Group.default.coupon_codes.all( :conditions => { :device_model_id => _devices, :coupon_code => 'default'}).length == 2
  end
  # WARNING: Sat Sep 18 00:11:16 IST 2010
  #   * Double check the default values
  # CHANGED: business logic changed. default group now has default coupon codes
  #
  # deault_coupon_code
  # t.date     "expiry_date"
  # t.integer  "deposit"
  # t.integer  "shipping"
  # t.integer  "monthly_recurring"
  # t.integer  "months_advance"
  # t.integer  "months_trial" 
  def default_coupon_code( device_type = 'Chest Strap' )
    device_model = DeviceType.find_by_device_type( device_type).device_models.first
    Group.default.coupon_codes.first( :conditions => { :coupon_code => "default", :device_model_id => device_model.id })
  end

  # groups applicable to user
  # Usage:
  #   Group.for_user( user)
  # QUESTION: how is user.group_memberships different from this?
  def self.for_user(user)
    user.is_a?(User) ? (user.is_super_admin? ? find(:all) : for_sales_or_admin_user(user)) : find(:all)
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
    users_with_role( "admin")
  end

  # ===================
  # = private methods =
  # ===================

  private

  def users_of_roles(roles)
    roles.blank? ? [] : roles.collect(&:users).flatten.uniq # return an array in all cases
  end

end