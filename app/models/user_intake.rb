# WARNING: to get proper behavior from user_intake instance for the views
#   Always call user_intake.build_associations immediately after creating an instance
#
require "lib/utility_helper"

class UserIntake < ActiveRecord::Base
  include UtilityHelper

  belongs_to :group
  belongs_to :order
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by"
  has_and_belongs_to_many :users # replaced with has_many :through
  has_many :user_intakes_users, :dependent => :destroy

  # https://redmine.corp.halomonitor.com/issues/3475
  #   Add two new fields in user intake form (Transmitter Serial # and Gateway Serial #)
  #   Add validation for transmitter(CS H1xxxxxxxx/BC H5xxxxxxxx) and gateway(H2xxxxxxxx)
  # validates_length_of :gateway_serial, :is => 10, :unless => :gateway_blank?
  # validates_length_of :transmitter_serial, :is => 10, :unless => :transmitter_blank?
  validates_format_of :gateway_serial, :with => /^H2.{8}$/, :unless => :gateway_blank?, :message => "is not formatted correctly"
  validates_format_of :transmitter_serial, :with => /^H[15].{8}$/, :unless => :transmitter_blank?, :message => "is not formatted correctly"
  validates_presence_of :subscriber, :unless => :subscribed_for_self?, :message => "is mandatory unless user is subscribing for itself"

  acts_as_audited
  # https://redmine.corp.halomonitor.com/issues/3215
  #   Comment out "Change All Dial Up Numbers" > update ticket #2809
  # validates_presence_of :local_primary, :global_primary, :unless => :skip_validation # https://redmine.corp.halomonitor.com/issues/2809
  named_scope :recent_on_top, :order => "updated_at DESC"

  # hold the data temporarily
  # user type is identified by the role it has subject to this user intake and other users
  # cmd_type : https://redmine.corp.halomonitor.com/issues/2809
  attr_accessor :mem_senior, :mem_subscriber, :need_validation, :cmd_type
  3.times do |index|
    attr_accessor "mem_caregiver#{index+1}".to_sym
    # 
    # Thu Nov  4 05:55:00 IST 2010, ramonrails
    # now use caregiver1_role_options instead of directly accessing this
    attr_accessor "mem_caregiver#{index+1}_options".to_sym
    attr_accessor "no_caregiver_#{index+1}".to_sym
  end
  attr_accessor :test_mode, :opt_out, :put_away, :card_or_bill, :lazy_action

  # =============================
  # = dynamic generated methods =
  # =============================

  [:gateway, :chest_strap, :belt_clip].each do |device|
    # Usage:
    #   user_intake.gateway
    #   user_intake.chest_strap     # returns a chest_strap or a belt_clip
    define_method device do
      # Wed Nov  3 03:07:02 IST 2010, ramonrails
      # https://redmine.corp.halomonitor.com/issues/3657
      # device should be fetched by serial number first, then through user
      # WARNING: this can be fatal. devices_users table is used elsewhere
      _device = Device.find_by_serial_number( device == :gateway ? gateway_serial : transmitter_serial )
      _device = self.senior.send(device) if (_device.blank? && !senior.blank? && !senior.send(device).blank?)
      _device
    end

    # Usage:
    #   user_intake.gateway_blank?
    #   user_intake.chest_strap_blank?
    define_method :"#{device}_blank?" do
      self.send( device).blank?
    end
  end

  # ==================
  # = public methods =
  # ==================

  #  TODO: FIXME: this should ideally go to user.rb but for the sake of time on 1.6.0 we kept it here
  #   * user object should hold the role_options if they are applicable
  #   * user should be able to identify "senior" through roles
  #
  #  Thu Nov  4 05:13:46 IST 2010, ramonrails 
  #   dynamic methods to fetch and assign roles_users_options for 3 caregivers 
  (1..3).each do |_index|
    # Usage:
    #   caregiver1_role_options
    #   caregiver2_role_options
    #   caregiver3_role_options
    define_method "caregiver#{_index}_role_options" do
      _options = self.send( "mem_caregiver#{_index}_options")
      if _options.blank?
        _caregiver = self.send("caregiver#{_index}")
        _options = ( self.new_record? ? RolesUsersOption.new( :position => _index) : _caregiver.options_for_senior( senior) ) if _options.blank?
        self.send("mem_caregiver#{_index}_options=", _options) # assign to mem
      end
      _options
    end
    
    # Usage
    #   caregiver1_role_options( _hash)
    #   caregiver1_role_options( RolesUsersOption.new( ... ) )
    #   caregiver1_role_options( roles_users_option_object )
    #   and similarly for other caregivers...
    define_method "caregiver#{_index}_role_options=" do |_given_options|
      _options = self.send( "mem_caregiver#{_index}_options")
      _caregiver = self.send("caregiver#{_index}")
      _options = ( self.new_record? ? RolesUsersOption.new( :position => _index) : _caregiver.options_for_senior( senior) ) if _options.blank?
      if _given_options.is_a?( RolesUsersOption)
        #  
        #   we have a roles_users_option object 
        _options = _given_options
      elsif _given_options.is_a?( Hash)
        #  
        #   we have a hash. apply attributes to which _options will respond 
        _given_options.each {|k,v| _options.send( "#{k}=", v) if _options.respond_to?( k) } # apply applicable hash values
      else
        #  
        #  Thu Nov  4 05:07:28 IST 2010, ramonrails 
        #    
        # If you have reached here, check your code. Please call the methods correctly
        # we can raise an exception here, but the user does not have to see that
      end
      self.send("mem_caregiver#{_index}_options=", _options) # assign to mem
      _options
    end
  end

  def subscribed_for_self?
    ["1", true].include?( subscriber_is_user) # subscriber is marked as user as well
  end

  def transmitter
    Device.find_by_serial_number( transmitter_serial) || chest_strap || belt_clip
  end

  def transmitter_blank?
    transmitter.blank? && chest_strap.blank? && belt_clip.blank?
  end

  def need_validation?
    need_validation
  end

  # for every instance, make sure the associated objects are built
  def after_initialize
    self.lazy_action = '' # keep it text. we need it for Approve, Bill actions
    self.bill_monthly = (!order.blank? && order.purchase_successful?) if self.new_record?
    self.need_validation = true # assume, the user will not hit "save"
    self.installation_datetime = (order.created_at + 7.days) if order and (group_id == Group.direct_to_consumer.id)
    # find(id, :include => :users) does not work due to activerecord design the way it is
    #   AR should ideally fire a find_with_associations and then initialize each object
    #   AR is not initializing the associations before it comes to this callback, in rails 2.1.0 at least
    #   this means, the associations do exist in DB, and found in query, but not loaded yet
    # 
    #   workaround
    #     initialize the associations only for new instance. we are safe
    #     call user_intake.build_associations in the code on user_intake instance
    self.subscriber_is_user = (subscriber_is_user.nil? || subscriber_is_user == "1")
    self.subscriber_is_caregiver = false if subscriber_is_caregiver.nil?
    (1..3).each do |index|
      #
      # for any new_record in memory, no_caregiver_x must be "on"
      _caregiver = self.send("caregiver#{index}")
      self.send("caregiver#{index}_role_options=".to_sym, ( self.new_record? ? { "position" => index } : _caregiver.options_for_senior( senior) ) )
      bool = self.send("no_caregiver_#{index}".to_sym)
      no_caregiver = ( (self.new_record? ? (bool != "0") : _caregiver.blank?) || _caregiver.nothing_assigned? )
      self.send("no_caregiver_#{index}=".to_sym, no_caregiver) # bool.blank? || 
    end
    build_associations
  end

  def before_save
    #
    # card or bill
    self.credit_debit_card_proceessed = (card_or_bill == "Card")
    self.bill_monthly = !credit_debit_card_proceessed
    # self.bill_monthly = (card_or_bill == "Bill")
    # self.credit_debit_card_proceessed = !bill_monthly
    # associations
    associations_before_validation_and_save # build the associations
    validate_associations # check validations unless "save"
    # WARNING: Need test coverage
    # lock if required
    # skip_validation decides if "save" was hit instead of "submit"
    self.locked = (!skip_validation && valid?)
    self.senior.update_attribute( :status, User::STATUS[:approval_pending]) if (locked? && self.senior.status.blank?) # once submitted, get ready for approval
    #
    # WARNING: Wed Sep 15 04:29:08 IST 2010
    #   this code causing some failures on business logic
    #   disabled until correctly resolved
    # # new logic. considers all status values as defined in STATUS
    # User.shift_to_next_status( senior.id, "user intake", updated_by) if (locked? && !senior.blank? && !self.new_record? && locked?)
    #
    # old logic. just checking for approval_pending
    # self.status = STATUS[:approval_pending] if (locked && status.blank?)
    #
    # CHANGED:
    #   This has now shifted to user.rb to create a triage audit log when changes to senior are made
    #   When the changes are only in user_intake, we have to force the log creation
    #
    # # create status row in triage_audit_log
    if !senior.blank? && senior.changed?
      options = { :updated_by => updated_by, :description => "Status updated from [#{senior.status_was}] to [#{senior.status}], triggered from user intake" }
      add_triage_note( options)
    end
    #  Wed Nov  3 05:00:46 IST 2010, ramonrails 
    #   anyways validate devices 
    validate_devices # validate the serial_numbers
  end

  def after_save
    # save the assoicated records
    associations_after_save
    # apply test mode, if applicable
    #
    #   * submitted the user intake with test_mode check box "on"
    #   * saved just now. created == updated
    senior.set_test_mode!( (test_mode == "1") || (created_at == updated_at) || self.new_record?) unless senior.blank? || senior.test_mode?
    # self.senior.send( :update_without_callbacks) # not required. set_test_mode! has "shebang"
    #
    # QUESTION: Should we consider a case here for panic test already received before "Approve"?
    # Switch user to installed state, if
    #   * user is "Ready to Install"
    #   * last user action was "Approve"
    # QUESTION: admin can approve?
    if lazy_action == "Approve" && senior.status == User::STATUS[:approval_pending] # && !self.updater.blank? && self.updater.is_super_admin?
      self.senior.update_attribute( :status, User::STATUS[:install_pending])
      self.senior.opt_in_call_center # start getting alerts, caregivers away, test_mode true

      # Switch user to installed state, if
      #   * user is "Ready to Bill"
      #   * last user action was "Bill"
    elsif lazy_action == 'Bill' && senior.status == User::STATUS[:bill_pending]
      #
      # charge subscription and pro-rata recurring charges (including today), only when installed
      unless order.blank?
        #
        # charge the credit card subscription now
        if order.charge_subscription
          #
          # pro-rata for subscription should also be charged
          order.charge_pro_rata  # charge the recurring cost calculated for remaining days of this month, including today
          #
          # now make user "Installed"
          self.senior.update_attribute( :status, User::STATUS[:installed])
          #
          # add a row to triage audit log
          #   cyclic dependency is not created. update_withut_callbacks is used in triage_audit_log
          attributes = {
            :user         => senior,
            :is_dismissed => senior.last_triage_status,
            :status       => senior.status,
            :created_by   => senior.id,
            :updated_by   => senior.id,
            :description  => "Transitioned from 'Ready to Bill' state to 'Installed'. Billed. Subscription charged. Pro-rata charged."
          }
          TriageAuditLog.create( attributes)
          #
          # explicitly send email to group admins, halouser, caregivers. tables are saved without callbacks
          [ senior, senior.has_caregivers, senior.group_admins ].flatten.uniq.each do |_user|
            UserMailer.deliver_user_installation_alert( _user)
          end
        end
      
      end
    end
    #
    # attach devices to user/senior
    senior.add_devices_by_serial_number( gateway_serial, transmitter_serial ) unless senior.blank?
    #
    # send email for installation
    # this will never send duplicate emails for user intake when senior is subscriber, or similar scenarios
    # UserMailer.deliver_signup_installation(senior)
    #
    # https://redmine.corp.halomonitor.com/projects/haloror/wiki/Intake_Install_and_Billing#Other-notes
    # https://redmine.corp.halomonitor.com/issues/3274
    # When the user intake is submitted
    #    1. For the first time, an email with entire profile is emailed to safetycare (CriticalMailer.senior_and_caregiver_details)
    #    2. Each subsequent time (super_admin only), only modified fields are emailed to safetycare (UserMailer.update_to_safety_care)
    # send email to safety_care when "Update" was hit on any status
    #   this should be ideally at user.after_save but we want this trigger at user_intake, not user

    # TODO: audit log is not in readable format for SafetyCare, redo in future release
    #if self.senior.status == User::STATUS[:approval_pending]
    if ["Submit", "Approve"].include?( lazy_action)
      UserMailer.deliver_senior_and_caregiver_details( self.senior)
      #else
      # Mon Nov  1 22:08:10 IST 2010
      #   Send update to safety care only when submitted for the first time
      #   * lazy_action is the button.text of user intake form, submitted by user
      #   * senior.status.blank? means the form is not yet "submitted", only "saved" so far, or created from online order
      #   * user intake can be submitted by "Submit" or "Approve" action, so they are checked
      #  
      #  Thu Nov  4 00:29:10 IST 2010, ramonrails 
      #   Emails to safety_care are never sent on any update to user intake
      # UserMailer.deliver_update_to_safety_care( self) if senior.status.blank? #acts_as_audited is not a good format to send to SafetyCare, defer for next release
    end
  end

  # when billing starts, the monthly recurring amount is charged pro-rated since this date
  def pro_rata_start_date
    installation_datetime || shipped_at || created_at
  end

  # create blank placeholder records
  # required for user form input
  def build_associations
    # assumption: the associations will build in the order of appearance, subject to ruby behavior
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each { |type| build_user_type(type) }
  end

  def skip_validation
    !self.need_validation
  end

  def skip_validation=(value = false)
    self.need_validation = !value
    skip_associations_validation # propogate it to associated records too
  end

  def validate
    if need_validation?
      associations_before_validation_and_save # pre-process associations
      validate_associations # validate associations and add errors to AR::Base to show on user intake form
    else
      skip_associations_validation # propogate to associated models
    end
  end

  def validate_associations
    if need_validation?
      validate_user_type("senior", true)
      validate_user_type("subscriber") unless subscribed_for_self? || senior_and_subscriber_match?
      validate_user_type("caregiver1") unless (subscriber_is_caregiver || ["1", true].include?( no_caregiver_1))
      validate_user_type("caregiver2") unless ["1", true].include?( no_caregiver_2)
      validate_user_type("caregiver3") unless ["1", true].include?( no_caregiver_3)
    end
  end

  # Wed Nov  3 02:47:19 IST 2010, ramonrails
  # validate the given serial numbers for devices present and available
  def validate_devices
    [gateway_serial, transmitter_serial].each do |_serial|
      errors.add_to_base("Device #{_serial} is not available. Please verify the serial number.") unless (_serial.blank? || Device.available?( _serial, senior))
    end
  end

  # collapse any associations to "nil" if they are just "new" (nothing assigned to them after "new")
  def collapse_associations
    # TODO: DRY this
    unless senior.nil?
      senior.collapse_associations
      senior.nothing_assigned? ? (self.senior = nil) : (self.senior.skip_validation = skip_validation)
    end

    unless subscriber.nil?
      if subscribed_for_self? || senior_and_subscriber_match?
        self.subscriber = nil # we have senior. no need of subscriber
      else
        subscriber.collapse_associations
        (subscriber.nothing_assigned? || subscribed_for_self? || senior_and_subscriber_match?) ? (self.subscriber = nil) : (self.subscriber.skip_validation = skip_validation)
      end
    end

    if !caregiver1.blank? && !["1", true].include?( no_caregiver_1) && !caregiver1.nothing_assigned? && !subscriber_is_caregiver
      self.caregiver1.skip_validation = true
    else
      self.caregiver1 = nil
    end

    if !caregiver2.blank? && !["1", true].include?( no_caregiver_1) && !caregiver2.nothing_assigned?
      self.caregiver2.skip_validation = true
    else
      self.caregiver2 = nil
    end

    if !caregiver3.blank? && !["1", true].include?( no_caregiver_1) && !caregiver3.nothing_assigned?
      self.caregiver3.skip_validation = true
    else
      self.caregiver3 = nil
    end

    # # FIXME: TODO. look when other bugs are fixed
    # # association are collapsing ignoring the params
    # # need most close debugging. Not getting a clue for now.
    # (1..3).each do |index|
    #   caregiver = self.send("caregiver#{index}".to_sym)
    #   unless caregiver.blank?
    #     no_caregiver = self.send("no_caregiver_#{index}".to_sym)
    #     if ["1", true].include?( no_caregiver)
    #       self.send("caregiver#{index}=".to_sym, nil) # when marked for no_caregiver_x, just remove the data
    #     else
    #       caregiver.collapse_associations
    #       if caregiver.nothing_assigned? || (index == 1 && subscriber_is_caregiver) || self.send("no_caregiver_#{index}".to_sym)
    #         self.send("caregiver#{index}=".to_sym, nil)
    #       else
    #         user = self.send("caregiver#{index}")
    #         unless user.nil?
    #           user.send("skip_validation=", skip_validation)
    #         end
    #       end
    #     end # caregiver1
    #   end
    # end
  end

  # pre-process data before validating
  # we are keeping senior, subscriber, ... in attr_accessor variables
  def associations_before_validation_and_save
    collapse_associations # make obsolete ones = nil
    #
    # TODO: conflicting with 1.6.0 pre-quality. removed to check compatiblity or related errors
    # for remaining, fill login, password details only when login is empty
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each {|user| autofill_user_login( user) }
    #
    # # assign roles to user objects. it will auto save the roles with user record
    # # TODO: use this instead of association_after_save that is assigning roles
    # self.senior.lazy_roles[:halouser]        = group  unless senior.blank? # senior.is_halouser_of group
    # self.subscriber.lazy_roles[:subscriber]  = senior unless subscriber.blank?
    # self.caregiver1.lazy_roles[:caregiver]   = senior unless caregiver1.blank?
    # self.caregiver2.lazy_roles[:caregiver]   = senior unless caregiver2.blank?
    # self.caregiver3.lazy_roles[:caregiver]   = senior unless caregiver3.blank?
    #
    # # now collect the users for save as associations
    # self.users = [senior, subscriber, caregiver1, caregiver2, caregiver3].uniq.compact # omit nil, duplicates
  end

  # create more data for the associations to keep them valid and associated
  # roles, options for roles
  def associations_after_save
    # WARNING: the associations here are not using active_record, so they are not auto saved with user intake
    #   we are saving the associations manually here
    collapse_associations # make obsolete ones = nil
    #
    # TODO: conflicting with 1.6.0 pre-quality. removed to check compatiblity or related errors
    # for remaining, fill login, password details only when login is empty
    # This is a 3 step process
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |_what|
      _user = self.send( _what) # fetch the associated user
      unless _user.blank? || _user.nothing_assigned?
        _user.skip_validation = true # TODO: patch for 1.6.0 release. fix later with business logic, if required

        _user.autofill_login # Step 1: make them valid
        _user.save # Step 2: save them to database
        self.users << _user # Step 3: link them to user intake
      end
    end
    #
    # add roles and options
    # TODO:
    #   * the roles are associated using user.lazy_roles.
    #   * We should avoid this block below and keep it in user model
    #   * just delegate the task to user model and let it handle
    # ----------------------- shift to user.rb - start -------------------------------
    # senior
    senior.is_halouser_of( group) unless senior.blank?
    # subscriber
    subscriber.is_subscriber_of( senior) unless senior.blank? || subscriber.blank?    
    # Wed Oct 27 23:55:22 IST 2010
    #   * no need to check subscriber_is_caregiver here. that is done in caregiver1 method
    #   * just call for each caregiver and assign position and other options
    (1..3).each do |index|
      _caregiver = self.send("caregiver#{index}".to_sym)
      unless (_caregiver.blank? || _caregiver.nothing_assigned?)
        _caregiver.is_caregiver_to( senior) # assign role
        # 
        # Thu Nov  4 05:57:16 IST 2010, ramonrails
        #   user values were stored with apply_attributes_from_hash
        #   now we persist them into database
        # debugger
        _options = self.send("caregiver#{index}_role_options")
        if RolesUsersOption.exists?( _options) # we are already at the record
          _options.save # just save it
        else # maybe this is a new association and options
          _caregiver.options_for_senior( senior, _options) # create appropriate data
        end
      end
    end
    # ----------------------- shift to user.rb - end -------------------------------
  end

  def add_triage_note( args = {})
    senior.add_triage_audit_log( args) unless ( args.blank? || senior.blank? )
  end

  def self.status_color( arg = '')
    STATUS_COLOR[ STATUS.index( arg) || :pending ]
  end

  # https://redmine.corp.halomonitor.com/issues/3215
  # messages for attributes statuses
  # * user intake detail view displays them besides the "submit" button
  def attributes_status_messages
    messages = []
    # messages << ( senior.blank? ? "Senior is blank" : nil)
    # # check all these attributes, but save processor time with condition within block
    messages += [ :senior, :installation_datetime, :created_by, :credit_debit_card_proceessed, :bill_monthly, :legal_agreement_at, :paper_copy_submitted_on, :created_at, :updated_at, :shipped_at, :sc_account_created_on ].collect {|e| e if self.send(e).blank? }
    # messages += [ :installation_datetime, :created_by, :credit_debit_card_proceessed, :bill_monthly,
    #   :legal_agreement_at, :paper_copy_submitted_on,
    #   :created_at, :updated_at ].collect {|e| self.send(e).blank? ? "#{e.to_s.gsub('_',' ').capitalize} is blank" : nil }
    # # check some methods too
    messages += [:chest_strap, :belt_clip, :gateway, :call_center_account].collect {|e| e if self.senior.send(e).blank? }
    # messages += [:chest_strap, :belt_clip, :gateway,
    #   :call_center_account].collect {|e| self.senior.send(e).blank? ? ("Senior does not have "+ e.to_s.gsub('_',' ').capitalize) : nil }
    # # dial_up_numbers should also be ok
    messages += :dial_up_numbers if dial_up_numbers_ok?
    # dial_up_numbers_ok? ? nil : "Dial up numbers are not as expected" # do not bother if already failed
    # messages.compact
    messages.flatten.compact.uniq.collect {|e| e.to_s.gsub('_',' ').capitalize }
  end

  # TODO: re-factoring required. delegate some part to user model
  # https://redmine.corp.halomonitor.com/issues/3213
  # * senior exist
  # * device identified by self.kit_serial_number exists for senior
  # * dial_up_numbers ok for senior for given device
  #
  # Sat Sep 25 00:45:06 IST 2010
  # CHANGED: logic changed to user.devices only. No user_intake.kit_serial_number

  def dial_up_numbers_ok?    
    (!senior.blank? && !senior.devices.gateways.first.blank?) ? senior.devices.gateways.first.dial_up_numbers_ok? : false
    #
    # Fri Sep 24 04:26:03 IST 2010
    # logic updated to check user.devices by type of device
    #
    # senior.blank? ? false : senior.dial_up_numbers_ok_for_device?( senior.device_by_serial_number( kit_serial_number))
  end

  def created_by_user_name
    created_by.blank? ? "" : (User.exists?(created_by) ? User.find(created_by).name : "")
  end

  # fetch all the admins for this group
  #   we are using authorization library calls here
  #   has_admins will return all objects that are defined
  #   * is_admin_of( this_group)
  #   * has_role( "admin", this_group) # same thing, different syntax
  def group_admins
    group.blank? ? [] : group.has_admins
  end

  def group_name
    group.blank? ? "" : group.name
  end

  def group_name=( name)
    self.group = Group.find_or_create_by_name( name)
  end

  def order_present?
    !order_id.blank?
  end

  def order_successful?
    order_present? && order.purchase_successful?
  end

  # Usage:
  #   user_intake.caregivers_active
  #   user_intake.caregivers_away
  ['active', 'away']. each do |_what|
    define_method "caregivers_#{_what}".to_sym do
      caregivers.select {|e| e.send("#{_what}_for?", senior) }.flatten.uniq
    end
  end

  # either the boolean is "on", or, the attributes have same values
  # FIXME: optimize after 1.6.0 release
  def senior_and_subscriber_match?
    senior.attributes.merge( senior.profile.attributes).values.compact == subscriber.attributes.merge( subscriber.profile.attributes).values.compact
  end

  # TODO: DRYness required here
  def senior
    if self.new_record?
      self.mem_senior
    else
      self.mem_senior ||= (users.select {|user| user.is_halouser_of?(group) }.first)
    end
    mem_senior
  end

  def senior=(arg)
    # debugger
    if arg == nil
      self.mem_senior = nil
    else
      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_senior = arg_user
        else
          user = (senior || arg_user)
          #
          # FIXME: WARNING: This might cause a bug. We cannot handle roles here. after-save does it already
          user.is_halouser_of( group) # self.group
          self.mem_senior = user # keep in instance variable so that attrbutes can be saved with user_intake
        end

        (self.mem_subscriber = User.new( mem_senior.attributes)) if subscribed_for_self? # same data, but clone
      end
    end
    self.mem_senior.skip_validation = self.skip_validation unless self.mem_senior.blank?
    self.mem_senior
  end

  def subscriber
    if subscribed_for_self?
      self.mem_subscriber = senior # return senior. do not assign here. this is READ mode method
      # self.mem_subscriber = senior # pick senior, if self subscribed
    else
      if self.new_record?
        self.mem_subscriber
      else
        self.mem_subscriber ||= (users.select {|user| user.is_subscriber_of?(senior) }.first )
      end
    end
    mem_subscriber
  end

  def subscriber=(arg)
    if arg == nil
      self.mem_subscriber = nil
    else

      if subscribed_for_self?
        self.senior = User.new( arg.attributes) if senior.blank? # we can use this data
        self.mem_subscriber = senior # assign to senior, then reference as subscriber
      else

        arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
        unless arg_user.blank?
          if self.new_record?
            self.mem_subscriber = arg_user # User.new(attributes)
          else
            user = (subscriber || arg_user)
            user.is_subscriber_of( senior) # self.senior
            self.mem_subscriber = user
          end

          # remember role option when subscriber is caregiver
          if subscriber_is_caregiver
            self.mem_caregiver1 = User.new( mem_subscriber.attributes) # clone
            # debugger
            # (self.mem_caregiver1_options = attributes["role_options"]) if attributes.has_key?("role_options")
          end
        end

      end
    end
    self.mem_subscriber.skip_validation = self.skip_validation unless self.mem_subscriber.blank?
    self.mem_subscriber
  end

  def caregiver1
    if subscriber_is_caregiver
      self.mem_caregiver1 = subscriber # subscriber code handles everything
    else
      if self.new_record?
        self.mem_caregiver1
      else
        self.mem_caregiver1 ||= (users.select {|user| user.caregiver_position_for(senior) == 1}.first || User.new) # fetch caregiver1 from users
      end
    end
    mem_caregiver1
  end

  def caregiver1=(arg)
    if (arg == nil) # || (!subscriber_is_caregiver && no_caregiver_1)
      self.mem_caregiver1 = nil
    else

      if subscriber_is_caregiver
        self.subscriber = arg if subscriber.blank? # we can use this data
        self.mem_caregiver1 = subscriber # assign to subscriber, then reference as caregiver1
      else

        arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
        unless arg_user.blank?
          if self.new_record?
            self.mem_caregiver1 = arg_user # User.new(attributes)
          else
            self.mem_caregiver1 = arg_user
          end

          # debugger
          # self.mem_caregiver1_options = attributes["role_options"] if attributes.has_key?("role_options")
        end

      end
    end
    self.mem_caregiver1.skip_validation = self.skip_validation unless self.mem_caregiver1.blank?
    self.mem_caregiver1
  end

  def caregiver2
    if self.new_record?
      self.mem_caregiver2
    else
      self.mem_caregiver2 ||= (users.select {|user| user.caregiver_position_for(senior) == 2}.first || User.new) # fetch caregiver2 from users
    end
    mem_caregiver2
  end

  def caregiver2=(arg)
    if (arg == nil) # || no_caregiver_2
      self.mem_caregiver2 = nil
    else

      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_caregiver2 = arg_user
        else
          self.mem_caregiver2 = arg_user
        end

        # self.mem_caregiver2_options = attributes["role_options"] if attributes.has_key?("role_options")
      end

    end
    self.mem_caregiver2.skip_validation = self.skip_validation unless self.mem_caregiver2.blank?
    self.mem_caregiver2
  end

  def caregiver3
    if self.new_record?
      self.mem_caregiver3
    else
      self.mem_caregiver3 ||= (users.select {|user| user.caregiver_position_for(senior) == 3}.first || User.new) # fetch caregiver3 from users
    end
    mem_caregiver3
  end

  def caregiver3=(arg)
    if (arg == nil) # || no_caregiver_3
      self.mem_caregiver3 = nil
    else

      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_caregiver3 = arg_user
        else
          self.mem_caregiver3 = arg_user
        end

        # self.mem_caregiver3_options = attributes["role_options"] if attributes.has_key?("role_options")
      end

    end
    self.mem_caregiver3.skip_validation = self.skip_validation unless self.mem_caregiver3.blank?
    self.mem_caregiver3
  end

  def caregivers
    [caregiver1, caregiver2, caregiver3].uniq.compact
  end

  # TODO: DRYness required here for methods

  # TODO: WARNING: needs more testing and code coverage
  def apply_attributes_from_hash( _hash)
    unless _hash.blank?
      #  
      #  Thu Nov  4 02:54:35 IST 2010, ramonrails 
      #   We can also do this, but no time for testing before 1.6.0 release
      #   _hash.each {|k,v| self.send("#{k}=", v) if self.respond_to?( k) }
      self.senior_attributes = _hash[:senior_attributes] unless _hash[:senior_attributes].blank?
      self.subscriber_attributes = _hash[:subscriber_attributes] unless (_hash[:subscriber_attributes].blank? || (_hash[:subscriber_is_user] == "1"))
      self.caregiver1_attributes = _hash[:caregiver1_attributes] unless (_hash[:caregiver1_attributes].blank? || (_hash[:subscriber_is_caregiver] == "1"))
      self.caregiver2_attributes = _hash[:caregiver2_attributes] unless _hash[:caregiver2_attributes].blank?
      self.caregiver3_attributes = _hash[:caregiver3_attributes] unless _hash[:caregiver3_attributes].blank?
      #
      # hide profiles on view, as appropriate
      self.subscriber_is_user = (subscribed_for_self? || senior_and_subscriber_match?)
      (1..3).each do |index|
        _caregiver = self.send("caregiver#{index}".to_sym)
        self.send("no_caregiver_#{index}=".to_sym, (_caregiver.blank? || _caregiver.nothing_assigned?))
        #  
        #  Thu Nov  4 02:52:39 IST 2010, ramonrails 
        #   Store the options into virtual attribute in user intake
        #   We will persist it to database during associations_after_save
        #   We need this because during the update_attributes, these virtual attributes do not get assigned
        # debugger
        self.send("caregiver#{index}_role_options=", _hash["caregiver#{index}_role_options"])
      end
    end
  end

  def senior_attributes=(attributes)
    # debugger
    unless attributes.blank?
      _profile_attributes = (attributes["profile_attributes"] || attributes[:profile_attributes])
      attributes = attributes.reject {|k,v| k.to_s == "profile_attributes" }
      self.senior = ((senior.blank? || self.new_record?) ? User.new(attributes) : self.senior.update_attributes(attributes)) # includes profile_attributes hash
      self.senior.profile_attributes = _profile_attributes # profile_attributes explicitly built
      self.senior.skip_validation = self.skip_validation unless self.senior.blank?
    end
    self.senior
  end

  def subscriber_attributes=(attributes)
    unless attributes.blank?
      _profile_attributes = (attributes["profile_attributes"] || attributes[:profile_attributes])
      attributes = attributes.reject {|k,v| k.to_s == "profile_attributes" }
      # (self.mem_caregiver1_options = attributes.delete("role_options")) if attributes.has_key?("role_options") && subscriber_is_caregiver
      self.subscriber = ((subscriber.blank? || self.new_record?) ? User.new( attributes) : self.subscriber.update_attributes(attributes)) # includes profile_attributes hash
      self.subscriber.profile_attributes = _profile_attributes # profile_attributes explicitly built
      self.subscriber.skip_validation = self.skip_validation unless self.subscriber.blank?
    end
    self.subscriber
  end

  def caregiver1_attributes=(attributes)
    unless attributes.blank?
      _profile_attributes = (attributes["profile_attributes"] || attributes[:profile_attributes])
      attributes = attributes.reject {|k,v| k.to_s == "profile_attributes" }
      # (self.mem_caregiver1_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
      self.caregiver1 = ((caregiver1.blank? || self.new_record?) ? User.new( attributes) : self.caregiver1.update_attributes(attributes)) # includes profile_attributes hash
      self.caregiver1.profile_attributes = _profile_attributes # profile_attributes explicitly built
      self.caregiver1.skip_validation = self.skip_validation unless self.caregiver1.blank?
    end
    self.caregiver1
  end

  def caregiver2_attributes=(attributes)
    unless attributes.blank?
      _profile_attributes = (attributes["profile_attributes"] || attributes[:profile_attributes])
      attributes = attributes.reject {|k,v| k.to_s == "profile_attributes" }
      # (self.mem_caregiver2_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
      self.caregiver2 = ((caregiver2.blank? || self.new_record?) ? User.new( attributes) : self.caregiver2.update_attributes(attributes)) # includes profile_attributes hash
      self.caregiver2.profile_attributes = _profile_attributes # profile_attributes explicitly built
      self.caregiver2.skip_validation = self.skip_validation unless self.caregiver2.blank?
    end
    self.caregiver2
  end

  def caregiver3_attributes=(attributes)
    unless attributes.blank?
      _profile_attributes = (attributes["profile_attributes"] || attributes[:profile_attributes])
      attributes = attributes.reject {|k,v| k.to_s == "profile_attributes" }
      # (self.mem_caregiver3_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
      self.caregiver3 = ((caregiver3.blank? || self.new_record?) ? User.new( attributes) : self.caregiver3.update_attributes(attributes)) # includes profile_attributes hash
      self.caregiver3.profile_attributes = _profile_attributes # profile_attributes explicitly built
      self.caregiver3.skip_validation = self.skip_validation unless self.caregiver3.blank?
    end
    self.caregiver3
  end

  def submitted?
    !submitted_at.blank? || !senior.status.blank? # timestamp is required to identify as "submitted"
  end

  # FIXME: DEPRECATED: QUESTION: this logic needs immediate attention. what to do here?
  def locked?
    submitted?
  end

  # FIXME: DEPRECATED: QUESTION: this logic needs immediate attention. what to do here?
  def locked=(status = nil)
    self.submitted_at = Time.now if (status && status == true)
    locked?
  end

  def agreement_signed?
    !self.legal_agreement_at.blank?
  end

  def can_sign_agreement?(user = nil)
    # sign only once
    # sign only when current_user is senior or subscriber
    (agreement_signed? || user.blank?) ? false : [senior, subscriber].include?(user)
  end

  def paper_copy_submitted?
    !paper_copy_at.blank? # paper_copy of the scubscriber agreement was submitted
  end

  def safety_care_email_sent
    # we just need to update date when email was sent to safety_care
    # no need to validate or callback for this
    self.emailed_on = Date.today
    self.send(:update_without_callbacks)
  end

  # ===================
  # = private methods =
  # ===================

  private

  # WARNING: This is conflicting with the 1.6.0 Pre-Quality
  #   Order from online store should create a user intake with blank login & password for all associated users
  #   This does not suit well wil existing user intake scenarios
  # Proposed action:
  #   comment out this method to see the affects in cucumber
  #   this can help to idenitfy all the issue quickly
  def autofill_user_login(user_type = "")
    unless user_type.blank?
      user = self.send("#{user_type}") # local copy, to keep code clean
      user.autofill_login if (!user.blank? && !user.nothing_assigned?)
      #
      # user_intake validation will fail if this is removed from here
      if user && user.login.blank? && !user.email.blank? # !user.blank? && user.login.blank?
        hex = Digest::MD5.hexdigest((Time.now.to_i+rand(9999999999)).to_s)[0..20]
        # only when user_type is not nil, but login is
        user.send("login=".to_sym, "_AUTO_#{hex}") # _AUTO_xxx is treated as blank
        user.send("password=".to_sym, hex)
        user.send("password_confirmation=".to_sym, hex)
      end
    end
  end

  def skip_associations_validation
    #
    # skip validations for all associated records
    [:senior, :subscriber, :caregiver1, :caregiver2, :caregiver3].each do |user_type|
      user = self.send(user_type)
      user.skip_validation = !need_validation unless user.blank? # and associated records
    end
  end

  # TODO: needs refactoring. Only build the requested user type.
  #   Optionally build all user types when no specific one is requested
  def build_user_type(user_type)
    # * building users is only required for new_record
    # * existing user_intake row will just load the caregiver, or set no_caregiver_x value
    if self.new_record?
      # instantiate the user type if not already exists
      self.send("#{user_type}=".to_sym, User.new) if self.send("#{user_type}".to_sym).nil?
      # roles_users_options for caregivers
      # checkboxes for existence of caregivers
      # (1..3).each do |index|
      index = user_type.to_i
      if user_type == "caregiver#{index}"
        if (user = self.send("#{user_type}".to_sym))
          self.send("caregiver#{index}_role_options=", {"position" => index}) if self.send("caregiver#{index}_role_options").blank?
          bool = self.send("no_caregiver_#{index}")
          #
          # for any new_record in memory, no_caregiver_x must be "on"
          self.send("no_caregiver_#{index}=".to_sym, (bool.nil? || self.new_record? || bool == "1") || user.nothing_assigned? )
        end
      end
      # end
      # build profile and other associations
      self.send("#{user_type}".to_sym).send("build_associations".to_sym) unless self.send("#{user_type}".to_sym).nil?

    else
      # existing user_intake row. just build the no_caregiver_x booleans
      (1..3).each do |index|
        _caregiver = self.send( "caregiver#{index}".to_sym)
        self.send("no_caregiver_#{index}=".to_sym, _caregiver.blank? || _caregiver.nothing_assigned? )
      end
    end
  end

  def validate_user_type(user_type, _force = false)
    #
    # user object should have its own validations. just use them instead of imposing here
    user = self.send("#{user_type}".to_sym)
    if user.blank?
      errors.add_to_base( "#{user_type} cannot be blank") if _force == true
    else
      errors.add_to_base( "#{user_type}: " + user.errors.full_messages.join(', ')) unless user.valid? || user.skip_validation
    end
    #
    # if user.blank?
    #   errors.add_to_base("#{user_type}: is mandatory")
    # else
    # 
    #   if user.need_validation?
    #     errors.add_to_base("#{user_type}: " + user.errors.full_messages.join(', ')) unless (user.skip_validation || user.valid?)
    #     if user.profile.blank?
    #       errors.add_to_base("#{user_type} profile: is mandatory") unless user.skip_validation
    #     else
    #       errors.add_to_base("#{user_type} profile: " + user.profile.errors.full_messages.join(', ')) unless (user.skip_validation || user.profile.valid?)
    #     end
    #   end
    # 
    # end
  end

  def argument_to_object(arg)
    if arg.is_a?(User)
      arg.profile_attributes = arg.profile_attributes if arg.respond_to?(:profile_attributes)
      arg
    else
      if arg.is_a?(Hash)
        user = User.new(arg)
        user.profile_attributes = arg[:profile_attributes] if arg.has_key?(:profile_attributes)
        user
      else
        nil
      end
    end
  end

end
