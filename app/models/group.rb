class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :emergency_numbers
  has_many :recurring_charges
  has_many :rmas
  has_many :rma_items
  has_many :orders
  has_many :roles, :as => :authorizable
  has_many :system_timeouts
  has_many :triage_thresholds
  # named_scope :distinct_by_name, :select => "DISTINCT name, *", :order => "name ASC"

  validates_format_of :name, :with => /\A[a-z0-9_]+\z/, :message => 'Only lowercase and numeric characters are allowed'
  
  # groups where user has "sales" or "admin" role
  # Usage:
  #   Group.for_sales_or_admin_user( User.first)
  named_scope :for_sales_or_admin_user, lambda { |user| 
      group_ids = user.group_memberships.collect {|group| (user.is_sales_of?(group) || user.is_admin_of?(group)) ? group.id : nil }.compact
      { :conditions => {:id => group_ids} }
    }

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

  # ------------ public methods
  
  class << self # class methods
    
    # dynamically define methods for some commonly used groups
    # Usage:
    #   Group.safety_care         # will find or create the "safety_care" group and return the active_record
    #   Group.direct_to_consumer
    #   Group.default
    [:safety_care, :direct_to_consumer, :default].each do |group_name|
      define_method group_name do
        find_or_create_by_name( group_name.to_s) # just create if required
      end
    end

    # dunamically created above
    # # Usage:
    # #   Group.direct_to_consumer
    # def direct_to_consumer
    #   find_or_create_by_name('direct_to_consumer')
    # end
    
    # groups applicable to user
    # Usage:
    #   Group.for_user( user)
    def for_user(user)
      user.is_a?(User) ? (user.is_super_admin? ? find(:all) : for_sales_or_admin_user(user)) : find(:all)
    end
    
  end # class methods

  # ---------- instance methods
  
  # we are not defining *args, &block here. we do not need them for now
  # Usage:
  #   Group.default.dialup_mode             # => "mode" by fetching value from SystemTimeout.defaults("dialup").mode
  #   Group.default.dialup_system_timeout   # returns the system_timeout
  # Incorrect usage:
  #   Group.default.abc               # => handled by super class (ActiveRecord)
  #   Group.safety_care.dialup_mode   # => error
  # Examples:
  # When calling in a valid way
  #     >> Group.default.dialup_group_id
  #       Group Load (0.002944)   SELECT * FROM "groups" WHERE ("groups"."name" = E'default') LIMIT 1
  #       SystemTimeout Load (0.003171)   SELECT * FROM "system_timeouts" WHERE ("system_timeouts"."mode" = E'dialup') LIMIT 1
  #       SQL (0.000535)   BEGIN
  #       SQL (0.000364)   COMMIT
  #       SystemTimeout Load (0.002279)   SELECT * FROM "system_timeouts" WHERE ("system_timeouts"."mode" IN (E'dialup')) 
  #       SystemTimeout Load (0.002392)   SELECT * FROM "system_timeouts" WHERE ("system_timeouts".group_id = 98 AND ("system_timeouts"."mode" = E'dialup')) LIMIT 1
  #     => 98
  # When calling this method invalid way
  #     >> Group.safety_care.dialup_group_id
  #       Group Load (0.001970)   SELECT * FROM "groups" WHERE ("groups"."name" = E'safety_care') LIMIT 1
  #       Group Load (0.001819)   SELECT * FROM "groups" WHERE ("groups"."name" = E'default') LIMIT 1
  #       Group Load (0.001632)   SELECT * FROM "groups" WHERE ("groups"."name" = E'default') LIMIT 1
  #       SystemTimeout Load (0.002425)   SELECT * FROM "system_timeouts" WHERE ("system_timeouts"."mode" = E'dialup') LIMIT 1
  #       SQL (0.000413)   BEGIN
  #       SQL (0.000316)   COMMIT
  #       SystemTimeout Load (0.002184)   SELECT * FROM "system_timeouts" WHERE ("system_timeouts"."mode" IN (E'dialup')) 
  #       SystemTimeout Load (0.002476)   SELECT * FROM "system_timeouts" WHERE ("system_timeouts".group_id = 4 AND ("system_timeouts"."mode" = E'dialup')) LIMIT 1
  #     NoMethodError: You have a nil object when you didn't expect it!
  #     The error occurred while evaluating nil.group_id
  #             from /Users/ram/work/projects/git/haloror/app/models/group.rb:87:in `send'
  #             from /Users/ram/work/projects/git/haloror/app/models/group.rb:87:in `method_missing'
  #             from (irb):69
  # TODO: can be dryed
  def method_missing( name)
    if name.blank?
      super
    else
      #
      # we assume that we are trying to call system_attribute methods here
      mode = name.to_s.split('_').first
      attribute = name.to_s.split('_')[1..-1].join('_') # atribute name
      if ["dialup", "ethernet"].include?( mode)
        SystemTimeout.ensure_defaults( mode) # ensure again that default values exist
        row = system_timeouts.first( :conditions => { :mode => mode }) # get the active record row
        if attribute == "system_timeout"
          row
        else
          if SystemTimeout.valid_attribute?( attribute)
            row.send(:"#{attribute}")
          else
            super
          end
        end
      else
        super # let ActiveRecord handle it
      end
    end
  end
    
  def users
    # all users having any role for this group
    # Usage:
    #   group.users
    users_of_roles(roles)
  end
  
  def users_with_role(role = nil)
    # all users having specific role in the group
    # Usage:
    #   group.users_with_role("admin")
    #   group.users_with_role(["admin", "sales"])
    users_of_roles(roles(:conditions => {:name => role}))
  end
  
  private # -----------------------------
  
  def users_of_roles(roles)
    roles.blank? ? [] : roles.collect(&:users).flatten.uniq # return an array in all cases
  end
  
end