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
  validates_format_of :gateway_serial, :with => /^H2[\d]{8}$/, :unless => :gateway_blank?
  validates_format_of :transmitter_serial, :with => /^H[15][\d]{8}$/, :unless => :transmitter_blank?

  acts_as_audited
  # https://redmine.corp.halomonitor.com/issues/3215
  #   Comment out "Change All Dial Up Numbers" > update ticket #2809
  # validates_presence_of :local_primary, :global_primary, :unless => :skip_validation # https://redmine.corp.halomonitor.com/issues/2809
  named_scope :recent_on_top, :order => "updated_at DESC"

  # WARNING: HALF BAKED. DO NOT USE UNESS CODE COVERED WITH TESTS
  # named_scope :identity_includes, lambda { |*args|
  #   arg = args.flatten.first
  #   include_this = arg.blank? # blank parameters means, include it
  #   unless include_this # unless not alreadu included
  #     unless senior.blank? # blank senior will not be included
  #       phrases = arg.split(',').collect(&:strip)
  #       # user intakes are selected here based on multiple criteria
  #       # * given csv phrase is split into csv_array
  #       # * user id, name, first_name, last_name from profile are checked against each element of csv_array
  #       # * name returns email or login, if profile is missing
  #       # * any given attribute of user can match at least one element of csv_array
  #       # if user is blank? do not select this user_intake
  #       # if user identity matches, select, else fail
  #       # senior exists && any identity column of senior matches at least one phrase (even partially)
  #       senior && [senior.id.to_s, senior.name, senior.first_name, senior.last_name].compact.uniq.collect do |e|
  #         found = phrases.collect {|f| e.include?( f) } # collect booleans for any phrase matching this identity column
  #         found && found.include?( true) # at least one match is TRUE
  #       end.include?( true) # collection must have at least one TRUE
  #     end
  #   end
  #   { :conditions => include_this } # return the boolean value to select/reject this row
  # }

  # hold the data temporarily
  # user type is identified by the role it has subject to this user intake and other users
  # cmd_type : https://redmine.corp.halomonitor.com/issues/2809
  attr_accessor :mem_senior, :mem_subscriber, :need_validation, :cmd_type
  (1..3).each do |index|
    attr_accessor "mem_caregiver#{index}".to_sym
    attr_accessor "mem_caregiver#{index}_options".to_sym
    attr_accessor "no_caregiver_#{index}".to_sym
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
      self.senior.send(device) if (!senior.blank? && !senior.send(device).blank?)
    end

    # Usage:
    #   user_intake.gateway_blank?
    #   user_intake.chest_strap_blank?
    define_method :"#{device}_blank?" do
      self.send( device).blank?
    end
  end

  def transmitter_blank?
    chest_strap.blank? && belt_clip.blank?
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
    # debugger
    self.subscriber_is_user = (subscriber_is_user.nil? || subscriber_is_user == "1")
    self.subscriber_is_caregiver = false if subscriber_is_caregiver.nil?
    (1..3).each do |index|
      self.send("mem_caregiver#{index}_options=".to_sym, {"position" => index}) if self.send("mem_caregiver#{index}_options".to_sym).nil?
      bool = self.send("no_caregiver_#{index}".to_sym)
      #
      # for any new_record in memory, no_caregiver_x must be "on"
      no_caregiver = (self.new_record? ? (bool != "0") : self.send("caregiver#{index}").blank?)
      self.send("no_caregiver_#{index}=".to_sym, no_caregiver) # bool.blank? || 
    end
    build_associations
  end

  def before_save
    # debugger
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
    self.senior.update_attribute_with_validation_skipping( :status, User::STATUS[:approval_pending]) if (locked? && self.senior.status.blank?) # once submitted, get ready for approval
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
    if lazy_action == "Approve" && senior.status == User::STATUS[:approval_pending]
        self.senior.update_attribute_with_validation_skipping( :status, User::STATUS[:install_pending])
        self.senior.opt_in_call_center # start getting alerts, caregivers away, test_mode true

    # Switch user to installed state, if
    #   * user is "Ready to Bill"
    #   * last user action was "Bill"
    elsif lazy_action == 'Bill' && senior.status == User::STATUS[:bill_pending]
      self.senior.update_attribute_with_validation_skipping( :status, User::STATUS[:installed])
      #
      # charge subscription and pro-rata recurring charges (including today), only when installed
      unless order.blank?
        #
        # charge the credit card subscription now
        order.charge_subscription
        #
        # pro-rata for subscription should also be charged
        order.charge_pro_rata  # charge the recurring cost calculated for remaining days of this month, including today
      end
    end
    #
    # connect devices to senior if they are free to use
    [transmitter_serial, gateway_serial].each do |_serial|
      #
      # fetch the existing device serial numbers
      _current_device_serials ||= self.senior.devices.collect(&:serial_number).collect(&:strip)
      #
      # do not re-attach if this serial is already attached
      unless _current_device_serials.include?( _serial) # do not bother if already linked
        #
        # fetch the device
        unless (device = Device.find_by_serial_number( _serial)).blank?
          #
          # attach it to the senior, only if
          #   * this device is exclusively attached to this senior
          #   * and of course, we can find this device in database :)
          self.senior.devices << device if device.is_associated_exclusively_to?( self.senior) # future proof? multiple devices?
        end
      end
    end
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
      UserMailer.deliver_senior_and_caregiver_details( self.senior)
    #else
      #UserMailer.deliver_update_to_safety_care( self)  #acts_as_audited is not a good format to send to SafetyCare, defer for next release
    #end
    #
    # attach devices to user/senior
    [gateway_serial, transmitter_serial].select {|e| !e.blank? }.each {|device| senior.add_device_by_serial_number( device) }
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
      validate_user_type("subscriber") unless subscriber_is_user
      validate_user_type("caregiver1") unless (subscriber_is_caregiver || ["1", true].include?( no_caregiver_1))
      validate_user_type("caregiver2") unless ["1", true].include?( no_caregiver_2)
      validate_user_type("caregiver3") unless ["1", true].include?( no_caregiver_3)
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
      if subscriber_is_user
        self.subscriber = nil # we have senior. no need of subscriber
      else
        subscriber.collapse_associations
        (subscriber.nothing_assigned? || subscriber_is_user) ? (self.subscriber = nil) : (self.subscriber.skip_validation = skip_validation)
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
    # assign roles to user objects. it will auto save the roles with user record
    # DEPRECATED: this will also trigger the email dispatch in observer
    self.senior.lazy_roles[:halouser]        = group  unless senior.blank? # senior.is_halouser_of group
    self.subscriber.lazy_roles[:subscriber]  = senior unless subscriber.blank?
    self.caregiver1.lazy_roles[:caregiver]   = senior unless caregiver1.blank?
    self.caregiver2.lazy_roles[:caregiver]   = senior unless caregiver2.blank?
    self.caregiver3.lazy_roles[:caregiver]   = senior unless caregiver3.blank?
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
    #
    # FIXME: we should not validate here. its done in "validate". just add roles etc here
    #
    # # senior
    senior.is_halouser_of( group) unless senior.blank?
    # unless senior.blank?
    #   senior.valid? ? senior.is_halouser_of( group) : self.errors.add_to_base("Senior not valid")
    # #   self.errors.add_to_base("Senior not valid") unless senior.valid?
    # #   self.errors.add_to_base("Senior profile needs more detail") unless senior.profile.nil? || senior.profile.valid?
    # end
    # subscriber
    subscriber.is_subscriber_of( senior) unless senior.blank? || subscriber.blank?
    # unless subscriber.blank?
    # subscriber.valid? ? subscriber.is_subscriber_of(senior) : self.errors.add_to_base("Subscriber not valid")
    # self.errors.add_to_base("Subscriber not valid") unless subscriber.valid?
    # self.errors.add_to_base("Subscriber profile needs more detail") unless subscriber.profile.nil? || subscriber.profile.valid?
    # save options
    caregiver1.options_for_senior(senior, mem_caregiver1_options.merge({:position => 1})) if subscriber_is_caregiver && !(caregiver1.blank? || subscriber.blank?)
    # end
    # caregivers
    3.times do |index| # will run 0..2
      # debugger
      caregiver = self.send("caregiver#{index+1}".to_sym)
      unless (caregiver.blank? || caregiver.nothing_assigned?)
        caregiver.is_caregiver_to( senior)
        # caregiver.valid? ? caregiver.is_caregiver_to(senior) : self.errors.add_to_base("Caregiver #{index} not valid")
        # self.errors.add_to_base("Caregiver #{index} not valid") unless caregiver.valid?
        # self.errors.add_to_base("Caregiver #{index} profile needs more detail") unless caregiver.profile.nil? || caregiver.profile.valid?
        # save options
        options = self.send("mem_caregiver#{index+1}_options")
        caregiver.options_for_senior(senior, options.merge({:position => index}))
      end
    end
  end

  # Fri Aug  6 21:29:55 IST 2010
  # these methods are now shifted to user.rb
  #
  # # additional information for the status at which this user intake is
  # # example:
  # #   ready for approval: each red "x" column described
  # def status_information
  #   case STATUS.index( status)
  #   when nil; '';
  #   when :approval_pending
  #     
  #   end
  # end
  # 
  # # find applicable key value from STATUS constant above
  # #   * status column is used to identify the key
  # #   * default = pending (blank or unknown status)
  # def status_index
  #   senior.status_index
  # end
  # 
  # # button text subject to status_index
  # #   :pending status will return "", so we need to cover that here
  # #   everything else is good
  # def status_button_text
  #   senior.status_button_text
  # end
  # 
  # def submit_button_text
  #   senior.submit_button_text
  # end
  # 
  # # button color for user_intake form
  # #   * we need to show gray when status in not found
  # #   * everything else is good
  # def status_button_color
  #   senior.status_button_color
  # end

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
    messages += [ :senior, :installation_datetime, :created_by, :credit_debit_card_proceessed, :bill_monthly,
      :legal_agreement_at, :paper_copy_submitted_on, :created_at, :updated_at, :shipped_at,
      :sc_account_created_on ].collect {|e| e if self.send(e).blank? }
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
    (!senior.blank? && !senior.gateway.blank?) ? senior.gateway.dial_up_numbers_ok? : false
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
    if arg == nil
      self.mem_senior = nil
    else
      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_senior = arg_user
        else
          user = (senior || arg_user)
          user.is_halouser_of( group) # self.group
          self.mem_senior = user # keep in instance variable so that attrbutes can be saved with user_intake
        end

        # debugger
        (self.mem_subscriber = User.new( mem_senior.attributes)) if subscriber_is_user # same data, but clone
      end
    end
    self.mem_senior.skip_validation = self.skip_validation unless self.mem_senior.blank?
    self.mem_senior
  end

  def subscriber
    if subscriber_is_user
      senior # return senior. do not assign here. this is READ mode method
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

      # debugger
      if subscriber_is_user
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
            (self.mem_caregiver1_options = attributes["role_options"]) if attributes.has_key?("role_options")
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
            user = (caregiver1 || arg_user)
            user.is_caregiver_of( senior) # self.senior
            self.mem_caregiver1 = user
          end

          self.mem_caregiver1_options = attributes["role_options"] if attributes.has_key?("role_options")
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
          user = (caregiver2 || arg_user)
          user.is_caregiver_of( senior) # self.senior
          self.mem_caregiver2 = user
        end

        self.mem_caregiver2_options = attributes["role_options"] if attributes.has_key?("role_options")
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
          user = (caregiver3 || arg_user)
          user.is_caregiver_of( senior) # self.senior
          self.mem_caregiver3 = user
        end

        self.mem_caregiver3_options = attributes["role_options"] if attributes.has_key?("role_options")
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
      self.senior_attributes = _hash[:senior_attributes] unless _hash[:senior_attributes].blank?
      self.subscriber_attributes = _hash[:subscriber_attributes] unless (_hash[:subscriber_attributes].blank? || (_hash[:subscriber_is_user] == "1"))
      self.caregiver1_attributes = _hash[:caregiver1_attributes] unless (_hash[:caregiver1_attributes].blank? || (_hash[:subscriber_is_caregiver] == "1"))
      self.caregiver2_attributes = _hash[:caregiver2_attributes] unless _hash[:caregiver2_attributes].blank?
      self.caregiver3_attributes = _hash[:caregiver3_attributes] unless _hash[:caregiver3_attributes].blank?
    end
  end

  def senior_attributes=(attributes)
    # debugger
    self.senior = ((senior.blank? || senior.new_record?) ? User.new(attributes) : self.senior.update_attributes(attributes)) # includes profile_attributes hash
    self.senior.profile_attributes = attributes[:profile_attributes] # profile_attributes explicitly built
    self.senior.skip_validation = self.skip_validation unless self.senior.blank?
    self.senior
  end

  def subscriber_attributes=(attributes)
    # debugger
    (self.mem_caregiver1_options = attributes.delete("role_options")) if attributes.has_key?("role_options") && subscriber_is_caregiver
    self.subscriber = ((subscriber.blank? || subscriber.new_record?) ? User.new( attributes) : self.subscriber.update_attributes(attributes)) # includes profile_attributes hash
    self.subscriber.profile_attributes = attributes[:profile_attributes] # profile_attributes explicitly built
    self.subscriber.skip_validation = self.skip_validation unless self.subscriber.blank?
    self.subscriber
  end

  def caregiver1_attributes=(attributes)
    (self.mem_caregiver1_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
    self.caregiver1 = ((caregiver1.blank? || caregiver1.new_record?) ? User.new( attributes) : self.caregiver1.update_attributes(attributes)) # includes profile_attributes hash
    self.caregiver1.profile_attributes = attributes[:profile_attributes] # profile_attributes explicitly built
    self.caregiver1.skip_validation = self.skip_validation unless self.caregiver1.blank?
    self.caregiver1
  end

  def caregiver2_attributes=(attributes)
    (self.mem_caregiver2_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
    self.caregiver2 = ((caregiver2.blank? || caregiver2.new_record?) ? User.new( attributes) : self.caregiver2.update_attributes(attributes)) # includes profile_attributes hash
    self.caregiver2.profile_attributes = attributes[:profile_attributes] # profile_attributes explicitly built
    self.caregiver2.skip_validation = self.skip_validation unless self.caregiver2.blank?
    self.caregiver2
  end

  def caregiver3_attributes=(attributes)
    (self.mem_caregiver3_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
    self.caregiver3 = ((caregiver3.blank? || caregiver3.new_record?) ? User.new( attributes) : self.caregiver3.update_attributes(attributes)) # includes profile_attributes hash
    self.caregiver3.profile_attributes = attributes["profile_attributes"] # profile_attributes explicitly built
    self.caregiver3.skip_validation = self.skip_validation unless self.caregiver3.blank?
    self.caregiver3
  end

  def submitted?
    !submitted_at.blank? # timestamp is required to identify as "submitted"
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
      # shifted to user.rb
      #
      # if user && user.login.blank? && !user.email.blank? # !user.blank? && user.login.blank?
      #   hex = Digest::MD5.hexdigest((Time.now.to_i+rand(9999999999)).to_s)[0..20]
      #   # only when user_type is not nil, but login is
      #   user.send("login=".to_sym, "_AUTO_#{hex}") # _AUTO_xxx is treated as blank
      #   user.send("password=".to_sym, hex)
      #   user.send("password_confirmation=".to_sym, hex)
      # end
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
      (1..3).each do |index|
        if user_type == "caregiver#{index}"
          if (user = self.send("#{user_type}".to_sym))
            self.send("mem_caregiver#{index}_options=".to_sym, {"position" => index}) if self.send("mem_caregiver#{index}_options".to_sym).nil?
            bool = self.send("no_caregiver_#{index}".to_sym)
            #
            # for any new_record in memory, no_caregiver_x must be "on"
            self.send("no_caregiver_#{index}=".to_sym, (bool.nil? || self.new_record? || bool == "1"))
          end
        end
      end
      # build profile and other associations
      self.send("#{user_type}".to_sym).send("build_associations".to_sym) unless self.send("#{user_type}".to_sym).nil?

    else
      # existing user_intake row. just build the no_caregiver_x booleans
      (1..3).each { |index| self.send("no_caregiver_#{index}=".to_sym, self.send( "caregiver#{index}".to_sym).blank? ) }
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
