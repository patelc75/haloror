# WARNING: to get proper behavior from user_intake instance for the views
#   Always call user_intake.build_associations immediately after creating an instance
# 
#  Sat Nov 13 00:38:45 IST 2010, ramonrails
#  TODO: A full test coverage of this model is absolutely mandatory to check all aspects
#
require "lib/utility_helper"

class UserIntake < ActiveRecord::Base
  include UtilityHelper

  belongs_to :group
  belongs_to :order
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by"
  belongs_to :device_model # https://redmine.corp.halomonitor.com/issues/4291
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

  # https://redmine.corp.halomonitor.com/issues/3215
  #   Comment out "Change All Dial Up Numbers" > update ticket #2809
  #   * https://redmine.corp.halomonitor.com/issues/3988
  # validates_presence_of :local_primary, :global_primary, :unless => :skip_validation # https://redmine.corp.halomonitor.com/issues/2809
  named_scope :without_group, :conditions => { :group_id => nil }
  named_scope :recent_on_top, :order => "updated_at DESC"

  acts_as_audited

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
  end
  attr_accessor :test_mode, :opt_out, :put_away, :lazy_action # , :card_or_bill

  # 
  #  Fri Nov 26 17:48:38 IST 2010, ramonrails
  #   * DEPRECATED: we are not using roles_users_option for caregiver position
  # serialize :caregiver_positions
  
  # =============================
  # = dynamic generated methods =
  # =============================

  (1..3).each do |_index|
    #   * GET
    define_method "caregiver#{_index}_role_options".to_sym do
      caregiver_role_options( _index)
    end
    
    #   * SET
    define_method "caregiver#{_index}_role_options=".to_sym do |_options|
      caregiver_role_options( _index, _options)
    end
  end
  # 
  #  Sat Jan  8 01:37:59 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3949
  #   * TODO: static methods not required anymore. dynamic method works
  # def caregiver1_role_options=( _options)
  #   caregiver_role_options( 1, _options)
  # end
  # 
  # def caregiver2_role_options=( _options)
  #   caregiver_role_options( 2, _options)
  # end
  # 
  # def caregiver3_role_options=( _options)
  #   caregiver_role_options( 3, _options)
  # end

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
  # Usage:
  #   caregiver_role_options
  #   caregiver_role_options( 1)
  #   caregiver_role_options( 2, {:position => 2})
  #   caregiver_role_options( 2, roles_users_option_instance)
  def caregiver_role_options( _index = 0, _given_options = nil)
    _options = nil # start with a blank
    if (1..3).include?( _index)
      _caregiver = self.send("caregiver#{_index}")
      # 
      # GET / SET mode. required for both
      # unless (_caregiver.blank? || _caregiver.nothing_assigned?)
        _options = self.send( "mem_caregiver#{_index}_options")
        _options ||= _caregiver.options_for_senior( senior)
        _options ||=  RolesUsersOption.new( :position => _index)

        # SET mode
        unless _given_options.blank?
          _given_options = if _given_options.is_a?( RolesUsersOption)
            #   we have a roles_users_option object 
            _given_options.clone.attributes
          elsif _given_options.is_a?( Hash) 
            #   we have a hash. apply attributes to which _options will respond 
            _given_options
          else
            #  Thu Nov  4 05:07:28 IST 2010, ramonrails 
            # If you have reached here, check your code. Please call the methods correctly
            # we can raise an exception here, but the user does not have to see that
            {}
          end
          # _given_options = _given_options # .reject { |k,v| (k == 'id') || (k[-3..-1] == '_id') } # exclude IDs
          _given_options.each {|k,v| _options.send( "#{k}=", v) if _options.respond_to?( "#{k}=".to_sym) } # apply applicable hash values
          #   * save when user does
          #   * mem_caregiverX_options also does the same at save
          _caregiver.lazy_options[ senior] = _options
          # _caregiver.options_for_senior( senior, _options) # persist
        end
        #   * we must assign this to memory attribute anyways
        if (_mem_options = self.send( "mem_caregiver#{_index}_options"))
          _mem_options.attributes = _options.attributes.reject { |k,v| (k == 'id') || (k[-3..-1] == '_id') }
          # _options.attributes.each { |k,v| _mem_options.send( "#{k}=", v) }
        end
        # self.send("mem_caregiver#{_index}_options=", _options) # assign to mem
      # end
      # 
      #  Fri Nov 19 02:38:23 IST 2010, ramonrails
      #   * for some reason like blank caregiver, we may get "nil" options
      #   * this will correct that situation
      _options ||=  RolesUsersOption.new( :position => _index)
    end
    _options
  end

  def subscribed_for_self?
    subscriber_is_user == true
  end

  def was_subscribed_for_self?
    subscriber_is_user_was == true
  end

  def caregiving_subscriber?
    subscriber_is_caregiver == true
  end

  def was_caregiving_subscriber?
    subscriber_is_caregiver_was == true
  end

  # Usage:
  #   caregiver1_required?
  #   caregiver2_required?
  #   caregiver3_required?
  (1..3).each do |_index|
    define_method "caregiver#{_index}_required?" do
      self.send( "no_caregiver_#{_index}") == false
    end
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

  # def just_submitted?
  #   submitted_at == updated_at
  # end

  # for every instance, make sure the associated objects are built
  def after_initialize
    self.lazy_action = '' # keep it text. we need it for Approve, Bill actions
    self.need_validation = true # assume, the user will not hit "save"
    # 
    #  Tue May 24 00:31:48 IST 2011, ramonrails
    #   * date should not be 7 days ahead, as discussed with Chirag on chat
    # self.installation_datetime ||= (order.created_at + 7.days) if ordered_direct_to_consumer?
    decide_card_or_bill
    # 
    #   * we begin from this state
    if self.new_record?
      self.no_caregiver_1 = true if no_caregiver_1.nil?
      self.no_caregiver_2 = true if no_caregiver_2.nil?
      self.no_caregiver_3 = true if no_caregiver_3.nil?
    end
    #
    # build before fetching caregiver options. also establishes
    #   * same as user
    #   * add as caregiver #1
    build_associations
    #
    self.subscriber_is_caregiver ||= subscriber_and_caregiver1_match?
  end

  def before_save
    #
    decide_card_or_bill # TODO: check why we need it here again after after_initialize
    #
    # self.bill_monthly = (card_or_bill == "Bill")
    # self.credit_debit_card_proceessed = !bill_monthly
    # associations
    associations_before_validation_and_save # build the associations
    validate_associations # check validations unless "save"
    # WARNING: Need test coverage
    # lock if required
    # skip_validation decides if "save" was hit instead of "submit"
    self.locked = (!submitted? && !skip_validation && valid?)
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
    if (lazy_action == "Approve") && (senior.status == User::STATUS[:approval_pending]) # && !self.updater.blank? && self.updater.is_super_admin?
      self.senior.status = User::STATUS[:install_pending]
      self.senior.send( :update_without_callbacks)
      self.senior.opt_in_call_center # start getting alerts, caregivers away, test_mode true

      # Switch user to installed state, if
      #   * user is "Ready to Bill"
      #   * last user action was "Bill"
    #   * subscription can be charged? trial period is over?
    elsif (lazy_action == 'Bill') && (senior.status == User::STATUS[:bill_pending]) && can_charge_subscription?
      # 
      #  Thu Feb  3 01:18:20 IST 2011, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/4137
      charge_pro_rata_and_subscription
    end
    #
    # attach devices to user/senior
    unless senior.blank?
      senior.add_devices_by_serial_number( gateway_serial, transmitter_serial )
      #
      # 
      #  Fri Dec  3 02:36:22 IST 2010, ramonrails
      #   * check for errors. report them on browser
      #   * FIXME: validation errors should be checked before_save, not after_save
      #   *   to do that, we need to delegate device assignment to user model
      _serials = senior.devices.collect(&:serial_number)
      [gateway_serial, transmitter_serial].each do |_serial|
        self.errors.add_to_base( "Device #{_serial} is not assigned to this halouser.") unless _serial.blank? || _serials.include?( _serial)
      end
    end
    #
    # send email for installation
    # this will never send duplicate emails for user intake when senior is subscriber, or similar scenarios
    # UserMailer.deliver_signup_installation(senior) unless senior.activated?
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
    # 
    #  Tue Nov 23 22:40:26 IST 2010, ramonrails
    #   * safety_care email dispatch is eliminated
    #   * https://redmine.corp.halomonitor.com/issues/3767
    #
    # if ["Submit", "Approve"].include?( lazy_action)
    #   UserMailer.deliver_senior_and_caregiver_details( self.senior)
    #   #else
    #   # Mon Nov  1 22:08:10 IST 2010
    #   #   Send update to safety care only when submitted for the first time
    #   #   * lazy_action is the button.text of user intake form, submitted by user
    #   #   * senior.status.blank? means the form is not yet "submitted", only "saved" so far, or created from online order
    #   #   * user intake can be submitted by "Submit" or "Approve" action, so they are checked
    #   #  
    #   #  Thu Nov  4 00:29:10 IST 2010, ramonrails 
    #   #   Emails to safety_care are never sent on any update to user intake
    #   # UserMailer.deliver_update_to_safety_care( self) if senior.status.blank? #acts_as_audited is not a good format to send to SafetyCare, defer for next release
    # end
    
    # 
    #  Fri Dec  3 02:29:51 IST 2010, ramonrails
    #   * check errors in payment_gateway_responses. report on browser
    # 
    #  Wed Feb  2 21:51:36 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4116
    #   * FIXME: validation errors should be checked before_save, not after_save
    if !order.blank? && !order.payment_gateway_responses.blank? && !order.payment_gateway_responses.failed.recent.blank?
      self.errors.add_to_base( order.payment_gateway_responses.failed.recent.collect(&:message).flatten.compact.uniq.join(', '))
    end
  end

  # 
  #  Thu Feb  3 01:17:13 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4137
  def charge_pro_rata_and_subscription
    #
    # charge subscription and pro-rata recurring charges (including today), only when installed
    unless order.blank?
      # 
      #  Fri Nov  5 06:29:06 IST 2010, ramonrails
      #  First charge pro-rata. That is one time. Then charge subscription.
      #  So, for some reason if subscription fails, we do not miss pro-rata charges
      #
      # pro-rata for subscription should also be charged
      if order.charge_pro_rata  # charge the recurring cost calculated for remaining days of this month, including today
        #
        # charge the credit card subscription now
        if order.charge_subscription
          #
          # now make user "Installed"
          # 
          #  Fri Apr  1 23:23:01 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4258
          if self.senior.any_panic_received?
            self.senior.update_attribute( :status, User::STATUS[:installed]) # force_status!( :installed)
          end
          # self.senior.status = User::STATUS[:installed]
          # self.senior.send( :update_without_callbacks)
          # 
          #  Fri Feb  4 01:05:28 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4147
          # #
          # # all caregivers are active now
          # caregivers.each { |e| e.set_active_for( senior, true) }
          #
          # add a row to triage audit log
          #   cyclic dependency is not created. update_withut_callbacks is used in triage_audit_log
          attributes = {
            :user         => senior,
            :is_dismissed => senior.last_triage_status,
            :status       => senior.status,
            :created_by   => self.updated_by, # senior.id,
            :updated_by   => self.updated_by, # senior.id,
            :description  => "Transitioned from 'Ready to Bill' state to 'Installed'. Billed. Subscription charged. Pro-rata charged."
          }
          TriageAuditLog.create( attributes)
          #
          # explicitly send email to group admins, halouser, caregivers. tables are saved without callbacks
          # 
          #  Wed Nov 24 23:01:26 IST 2010, ramonrails
          #   * https://spreadsheets0.google.com/ccc?key=tCpmolOCVZKNceh1WmnrjMg&hl=en#gid=4
          #   * https://redmine.corp.halomonitor.com/issues/3785
          #   * shifted to variable to reduce double call
          _email_to = [ senior.group_admins, subscriber, group, group.master_group
            ].flatten.compact.collect(&:email).compact.insert( 0, "senior_signup@halomonitoring.com").uniq            
          # 
          #  Mon Feb  7 21:26:10 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4146#note-6
          # #   * include caregivers as they were earlier
          # (_email_to + senior.has_caregivers.collect(&:email)).flatten.compact.uniq.each do |_email|
          #   #   * send installation intimations
          #   UserMailer.deliver_user_installation_alert( senior, _email)
          # end
          # 
          #  Thu Feb  3 23:51:32 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4146
          #   * when both charges are green, send these emails
          #   * we collected these emails in a variable already. caregivers do not get this email
          _email_to.each { |_email| UserMailer.deliver_subscription_start_alert( senior, _email) }
        end
      end

    end
  end

  def decide_card_or_bill
    self.credit_debit_card_proceessed = (!order.blank? && order.purchase_successful?) # online store means card was used
    self.bill_monthly = !credit_debit_card_proceessed
  end

  def ordered_direct_to_consumer?
    !order.blank? && (group_id == Group.direct_to_consumer.id)
  end

  # 
  #  Thu Dec  2 00:40:59 IST 2010, ramonrails
  #   * decide whether pro-rata and subscription can be charged right now, or a trial period is running?
  def can_charge_subscription?
    #   * cannot charge subscription until trial period is running
    #   * can only charge with a valid shipped_at or panic event
    !order.blank? && !subscription_deferred? && ( senior.any_panic_received? || !shipped_at.blank?)
  end

  # 
  #  Thu Dec  2 01:32:49 IST 2010, ramonrails
  #   * checks if trial period is still running
  # WARNING: This has a very major bug. to produce
  #   * make a coupon code with no advance, 2 months trial
  #   * create an order with that
  #   * get user intake to "ready to bill" state
  #   * change coupon code to, 2 months advance, no trial
  #   * FIXME: now we have not received 2 months payment but user gets benefit
  def subscription_deferred?
    #   * trial period will end one day less than trial-period-span-months-window
    !order.blank? && !order.product_cost.blank? && (Date.today < (order.created_at.to_date + order.product_cost.recurring_delay.months))
  end
  
  # when billing starts, the monthly recurring amount is charged pro-rated since this date
  #  Tue May 24 20:29:19 IST 2011, ramonrails
  #   * amount is charged from the copy of recurring rate stored in order at the time of placing it
  #   * changes to the coupon code after placing the order does not affect this
  def pro_rata_start_date
    # 
    #  Tue Nov 23 00:53:04 IST 2010, ramonrails
    #   * we will never use "installation_datetime"
    #   * installation_datetime is the "desired" installation datetime
    #   * Pro-rata is charged from the date a panic button is received making user ready to install
    #
    #   * check panic button press
    _date = panic_received_at
    #   * no panic? check shipping date
    _date ||= (shipped_at + 7.days) unless shipped_at.blank? # if ( _date.blank? && !shipped_at.blank? )
    #   * no panic or shipping? nothing returned
    # # 
    # #  Wed Mar 30 03:46:04 IST 2011, ramonrails
    # #   * https://redmine.corp.halomonitor.com/issues/4253
    # #   * pick local values that were copied
    # #   * when missing?, pick from device_model_prices
    # unless (order.blank? || order.product_cost.blank? || _date.blank?)
    #   _date += ( order.cc_monthly_recurring || order.product_cost.recurring_delay).to_i.months
    # end
    # # 
    # #  Tue May 24 20:07:41 IST 2011, ramonrails
    # #   * https://redmine.corp.halomonitor.com/issues/4486
    # #   * https://redmine.corp.halomonitor.com/attachments/3294/invalid_prorate_start_dates.jpg
    # _date ||= Date.today
    # _date = Date.today if _date > Date.today
    # _date
  end
  
  # 
  #  Fri Feb  4 00:25:57 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4146
  def pro_rata_end_date
    subscription_start_date - 1.day # unless subscription_start_date.blank?
  end
  
  # 
  #  Wed Feb 16 00:23:52 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4199
  def pro_rated_days
    _date_begin = pro_rata_start_date
    _date_end = subscription_start_date
    if _date_begin.blank? || _date_end.blank?
      0
    else
     ((_date_end - _date_begin) / 1.day).round(0).to_i # n days
    end
  end
  
  # 
  #  Wed Feb 16 00:41:18 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4199
  def subscription_start_date
    # if (_subscribed_at = subscription_started_at)
    #   #   * if the subscription already started, no point calulating again
    #   _subscribed_at
    # else
      #   * if no subscription started yet, consider this month
      _date = Time.now
      if _date.day == 1
        _date.to_date # if today is 1st, why wait? start the subscription from today
      else
        (_date + 1.month).beginning_of_month.to_date # .to_date # today is not 1st, let this month be pro-rated
      end
  end
  
  # 
  #  Wed Feb 16 00:30:04 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4199
  def subscription_started_at
    order.subscription_started_at unless order.blank?
  end

  # create blank placeholder records
  # required for user form input
  def build_associations
    #
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
    #  Wed Nov  3 05:00:46 IST 2010, ramonrails 
    #   ignore any flags and force validate devices
    validate_devices # validate the serial_numbers
  end

  def validate_associations
    if need_validation?
      validate_user_type("senior", true)
      validate_user_type("subscriber") unless subscribed_for_self? || senior_and_subscriber_match?
      validate_user_type("caregiver1") unless (caregiving_subscriber? || !caregiver1_required?)
      validate_user_type("caregiver2") unless !caregiver2_required?
      validate_user_type("caregiver3") unless !caregiver3_required?
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
    if senior.blank? || senior.nothing_assigned?
      senior.collapse_associations
      self.mem_senior = nil
    end

    unless subscriber.blank? || subscriber.nothing_assigned?
      if subscribed_for_self? || senior_and_subscriber_match?
        subscriber.collapse_associations
        self.mem_subscriber = nil # we have senior. no need of subscriber
      end
    end

    if caregiver1.blank? || !caregiver1_required? || caregiver1.nothing_assigned? || caregiving_subscriber?
      self.caregiver1 = nil
    end

    if caregiver2.blank? || !caregiver2_required? || caregiver2.nothing_assigned?
      self.caregiver2 = nil
    end

    if caregiver3.blank? || !caregiver3_required? || caregiver3.nothing_assigned?
      self.caregiver3 = nil
    end
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
    #  Fri Nov 12 18:12:01 IST 2010, ramonrails
    #   * these are mandatory to dispatch emails in user model
    #   * a user must know the role while saving itself
    # assign roles to user objects. it will auto save the roles with user record
    # TODO: use this instead of association_after_save that is assigning roles
    self.senior.lazy_roles[:halouser]                = group  unless senior.blank? # senior.is_halouser_of group
    self.subscriber.lazy_roles[:subscriber]          = senior unless subscriber.blank?
    self.caregiver1.lazy_roles[:caregiver]           = senior unless caregiver1.blank?
    self.caregiver2.lazy_roles[:caregiver]           = senior unless caregiver2.blank?
    self.caregiver3.lazy_roles[:caregiver]           = senior unless caregiver3.blank?
    self.caregiver1.lazy_options[ senior ] = mem_caregiver1_options
    self.caregiver2.lazy_options[ senior ] = mem_caregiver2_options
    self.caregiver3.lazy_options[ senior ] = mem_caregiver3_options
    #
    # # now collect the users for save as associations
    # self.users = [senior, subscriber, caregiver1, caregiver2, caregiver3].uniq.compact # omit nil, duplicates
  end

  # create more data for the associations to keep them valid and associated
  # roles, options for roles
  def associations_after_save
    # # WARNING: the associations here are not using active_record, so they are not auto saved with user intake
    # #   we are saving the associations manually here
    # collapse_associations # make obsolete ones = nil
    #
    # TODO: conflicting with 1.6.0 pre-quality. removed to check compatiblity or related errors
    # for remaining, fill login, password details only when login is empty
    # This is a 3 step process
    # 
    #  Thu Nov 11 00:14:24 IST 2010, ramonrails
    #  Link per user, once only. compact.uniq ensures that
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |_what|
      # 
      #  Sat Nov 20 02:03:52 IST 2010, ramonrails
      #   * this logic is required when uset simply toggles the flag and saves
      _user = self.send( _what) # fetch the associated user
      unless _user.blank? || _user.nothing_assigned?
        #   * default properties
        _user.autofill_login # create login and password if not already
        _user.lazy_associations[:user_intake] = self
        _user.skip_validation = true # TODO: patch for 1.6.0 release. fix later with business logic, if required

        case _what
        when 'senior'
          # _user.save
          # _user.is_halouser_of( group) unless _user.blank? || group.blank? # role
          _user.lazy_roles[:halouser] = group unless _user.blank? || group.blank? # role
          _user.save
          
        when 'subscriber'
          if subscribed_for_self? # senior is same as subscriber
            if was_subscribed_for_self?
              #   * user and subscriber are same. not changed
            else
              #   * subscriber was different. now same as senior
              self.subscriber_is_user = false # create old condition
              subscriber.is_not_subscriber_of( senior) unless subscriber.blank? || senior.blank? # remove old role first
              # subscriber.delete # remove this extra user
              self.subscriber_is_user = true # back to current situation
            end
            # _user.save
            # _user.is_subscriber_of( senior) unless _user.blank? || senior.blank? # role
            _user.lazy_roles[:subscriber] = senior unless _user.blank? || senior.blank? # role
            _user.save

          else # senior different from subscriber
            if was_subscribed_for_self?
              _user = senior.clone_with_profile if senior.equal?( subscriber) # same IDs, clone first
              senior.is_not_subscriber_of( senior) unless senior.blank? # senior was subscriber, not now
            else
              # all good. nothing changed
            end
            # _user.save
            # _user.is_subscriber_of( senior) unless _user.blank? || senior.blank? # role
            _user.lazy_roles[:subscriber] = senior unless _user.blank? || senior.blank? # role
            _user.save
          end
          
        when 'caregiver1'
          if caregiving_subscriber? # subscriber is caregiver
            if was_caregiving_subscriber?
              # all good. nothing changed
            else
              # was separate
              self.subscriber_is_caregiver = false # make old condition
              caregiver1.is_not_caregiver_of( senior) unless caregiver1.blank? || senior.blank?
              # caregiver1.delete # remove extra
              self.subscriber_is_caregiver = true # current condition again
            end
            
          else # subscriber different from caregiver1
            if was_caregiving_subscriber?
              _user = subscriber.clone_with_profile if subscriber.equal?( caregiver1) # same ID? clone first
              subscriber.is_not_caregiver_of( senior) unless subscriber.blank? || senior.blank? # remove caregiving role for subscriber
            else
              # all good. nothing changed
            end
          end
          if caregiving_subscriber? || (caregiver1_required? && _user.something_assigned? && !senior.blank? && !_user.equal?( senior))
            # _user.save
            # _user.is_caregiver_of( senior) unless _user.blank? || senior.blank? || _user.equal?( senior)
            # _user.options_for_senior( senior, mem_caregiver1_options)
            _user.lazy_roles[:caregiver] = senior
            _user.lazy_options[ senior] = mem_caregiver1_options
            _user.save
          # else
          #   self.no_caregiver_1 = true
          #   self.send(:update_without_callbacks)
          end
          
        when 'caregiver2'
          if caregiver2_required? && _user.something_assigned? && !senior.blank? && !_user.equal?( senior)
            # _user.save
            # _user.is_caregiver_of( senior) unless _user.blank? || senior.blank? || _user.equal?( senior)
            # _user.options_for_senior( senior, mem_caregiver2_options)
            _user.lazy_roles[:caregiver] = senior
            _user.lazy_options[ senior] = mem_caregiver2_options
            _user.save
          else
            self.no_caregiver_2 = true
            self.send(:update_without_callbacks)
          end

        when 'caregiver3'
          if caregiver3_required? && _user.something_assigned? && !senior.blank? && !_user.equal?( senior)
            # _user.save
            # _user.is_caregiver_of( senior) unless _user.blank? || senior.blank? || _user.equal?( senior)
            # _user.options_for_senior( senior, mem_caregiver3_options)
            _user.lazy_roles[:caregiver] = senior
            _user.lazy_options[ senior] = mem_caregiver3_options
            _user.save
          else
            self.no_caregiver_3 = true
            self.send(:update_without_callbacks)
          end
        end # case
      end # blank?
    end # _what
    
    # 
    #  Thu Jan 13 02:38:38 IST 2011, ramonrails
    #   * Not required anymore
    #   * lazy_associations attaches each user to this user intake
    # #
    # #   * replace earlier associations. keep fresh ones
    # #   * do not create duplicate associations
    # # QUESTION: what happens to orphaned users here?
    # #   * reject new_record? anything not saved does not get assigned
    # #   * only associate one copy of each
    # self.users = [senior, subscriber, caregiver1, caregiver2, caregiver3].reject(&:new_record?).compact.uniq
    # # # 
    # # #  Thu Jan 13 02:34:27 IST 2011, ramonrails
    # # #   * pre_quality.feature had error dispatching emails
    # # #   * This might dispatch the email more than once
    # # self.users.each(&:dispatch_emails)


    # ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each do |_what|
    #   
    #   # 
    #   #  Fri Nov 19 03:17:32 IST 2010, ramonrails
    #   #   * skip saving the object if already saved
    #   #   * happens when object is shared. subscriber == user, or, subscriber == caregiver
    #   #   * saving also dispatches emails. A few more triggers/callbacks. Please check model code
    #   _skip = ((_what == 'subscriber') && subscribed_for_self?)
    #   _skip = (_skip || (_what == 'caregiver1' && caregiving_subscriber?))
    #   # 
    #   #  Thu Nov 11 00:32:18 IST 2010, ramonrails
    #   #  Do not save any non-assigned data, or blank ones
    #   unless _user.blank? || _user.nothing_assigned? || _skip
    #     _user.skip_validation = true # TODO: patch for 1.6.0 release. fix later with business logic, if required
    # 
    #     # _user.autofill_login # Step 1: make them valid
    #     if _user.save # Step 2: save them to database
    #       # 
    #       #  Thu Nov 11 00:13:31 IST 2010, ramonrails
    #       #  https://redmine.corp.halomonitor.com/issues/3696
    #       #   caused a bug that created multiple links to the same user
    #       self.users << _user unless users.include?( _user) # Step 3: link them to user intake
    #     end
    #   end
    # end
    # #
    # #   * add roles and options
    # #   * roles are already handled by user model
    # #   * this will not double write the roles
    # # senior
    # senior.is_halouser_of( group) unless senior.blank?
    # # subscriber
    # unless senior.blank? || subscriber.blank?
    #   subscriber.is_subscriber_of( senior)
    #   subscriber.is_caregiver_of( senior) if caregiving_subscriber?
    # end
    # # Wed Oct 27 23:55:22 IST 2010
    # #   * no need to check subscriber_is_caregiver here. that is done in caregiver1 method
    # #   * just call for each caregiver and assign position and other options
    # (1..3).each do |index|
    #   _caregiver = self.send("caregiver#{index}".to_sym)
    #   _required = self.send("caregiver#{index}_required?")
    #   unless (_caregiver.blank? || !_required || _caregiver.nothing_assigned?)
    #     _caregiver.is_caregiver_of( senior) unless _caregiver.is_caregiver_of?( senior)
    #     # 
    #     # Thu Nov  4 05:57:16 IST 2010, ramonrails
    #     #   user values were stored with apply_attributes_from_hash
    #     #   now we persist them into database
    #     _options = self.send("mem_caregiver#{index}_options")
    #     # 
    #     #  Thu Nov 18 20:58:29 IST 2010, ramonrails
    #     #   * Do not use any other method here, cyclic dependency can occur
    #     _caregiver.options_for_senior( senior, _options)
    #   end
    # end

  end

  # 
  #  Thu Jan  6 00:20:58 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3937
  def action_required?
    !senior.blank? && !senior.triage_audit_logs.blank? && senior.triage_audit_logs.action_required.length > 0
  end

  def add_triage_note( args = {})
    senior.add_triage_audit_log( args) unless ( args.blank? || senior.blank? )
  end

  def status_color( arg = '')
    senior.blank? ? 'gray' : senior.status_button_color
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
    # 
    #  Mon Nov 22 16:55:15 IST 2010, ramonrails
    #   * find_or_create is not appropriate
    self.group = Group.find_by_name( name) # or_create_
  end

  def order_present?
    !order_id.blank?
  end

  def order_successful?
    order_present? && order.purchase_successful?
  end

  def subscription_successful?
    order_present? && order.subscription_successful?
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
    # 
    #  Fri Nov 12 00:15:39 IST 2010, ramonrails
    #  when either of them is blank?, this may cause error in browser
    #   * senior attributes
    if senior.blank?
      _senior_attributes = {}
    else
      _senior_attributes = senior.attributes
      _senior_attributes.merge( senior.profile.attributes) unless senior.profile.blank?
    end
    # 
    #   * subscriber attrbutes
    if subscriber.blank?
      _subscriber_attributes = {}
    else
      _subscriber_attributes = subscriber.attributes
      _subscriber_attributes.merge( subscriber.profile.attributes) unless subscriber.profile.blank?
    end
    # 
    #   * check for the match among attributes
    _senior_attributes.values.compact == _subscriber_attributes.values.compact
  end

  def subscriber_and_caregiver1_match?
    # 
    #   * subscriber attributes
    if subscriber.blank?
      _subscriber_attributes = {}
    else
      _subscriber_attributes = subscriber.attributes
      _subscriber_attributes.merge( subscriber.profile.attributes) unless subscriber.profile.blank?
    end
    # 
    #   * caregiver1 attrbutes
    if caregiver1.blank?
      _caregiver1_attributes = {}
    else
      _caregiver1_attributes = caregiver1.attributes
      _caregiver1_attributes.merge( caregiver1.profile.attributes) unless caregiver1.profile.blank?
    end
    # 
    #   * check for the match among attributes
    _subscriber_attributes.values.compact == _caregiver1_attributes.values.compact
  end

  # # 
  # #  Tue Nov 16 18:53:33 IST 2010, ramonrails
  # #  caregiver positions stored locally
  # def local_caregiver( _index = 0, _user = nil)
  #   if (1..3).include?(_index) # index range
  #     if _user.blank?
  #       # GET
  #       User.find( caregiver_positions[_index] ) if !caregiver_positions.blank? && caregiver_positions.has_key?( _index)
  #     else
  #       # SET
  #       self.caregiver_positions ||= {}
  #       self.caregiver_positions[_index] = _user.id
  #       _user
  #     end
  #   end # index range
  # end

  # 
  #  Thu Feb 10 02:22:55 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/4119#note-25
  #   * this is different from "senior"
  #   * "senior" uses "halouser" to select the user
  #   * "halouser" if not buffered. it is always fetched from database
  def halouser
    users.select {|e| e.is_halouser_of?(group) }.sort {|a,b| b.created_at <=> a.created_at }.first
  end
  
  # TODO: DRYness required here
  def senior
    #   * pickup any exiting from mem_... attribute
    #   * fetch using the role, when above fails
    #   * insitantiate a new if all above failed
    #   * Assign the final instance to mem... attribute, for next time
    # 
    #  Sat Jan 29 00:32:43 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4119
    #   * pick up the most recent one (sort b <> a) if multiple halousers exist for some reason
    #   * FIXME: we should never have multiple halousers for a user intake
    self.mem_senior ||= ( halouser || User.new.clone_with_profile)
  end

  def senior=( arg)
    apply_attributes_to_object( arg, senior)
  end

  def subscriber
    # 
    #  Sat Jan 29 00:32:43 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4119
    #   * pick up the most recent one (sort b <> a) if multiple subscribers exist for some reason
    #   * FIXME: we should never have multiple subscribers for a user intake
    self.mem_subscriber ||= ( (users.select {|e| e.is_subscriber_of?(senior) }.sort {|a,b| b.created_at <=> a.created_at }.first) || User.new.clone_with_profile)
    if subscribed_for_self? # senior and subscriber same
      if was_subscribed_for_self?
        # nothing changed
      else
        # senior will be returned
      end
    else # senior is different from subscriber
      if was_subscribed_for_self?
        self.mem_subscriber = User.new.clone_with_profile if mem_senior.equal?( mem_subscriber) # clone if same object
      else
        # nothing changed
      end
    end
    subscribed_for_self? ? senior : mem_subscriber
  end

  def subscriber=(arg)
    subscribed_for_self? ? subscriber : apply_attributes_to_object( arg, subscriber)
  end

  def caregiver1
    # 
    #  Sat Jan 29 00:32:43 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4119
    #   * pick up the most recent one (sort b <> a) if multiple roles exist for some reason
    self.mem_caregiver1 ||= ( (users.select {|e| e.caregiver_position_for(senior) == 1}.sort {|a,b| b.created_at <=> a.created_at }.first) || User.new.clone_with_profile)
    if caregiving_subscriber? # subscriber is caregiver
      if was_caregiving_subscriber?
        # nothing changed
      else
        # subscriber will be returned
      end
    else # subscriber is not ceregiver
      if was_caregiving_subscriber?
        # clone
        self.mem_caregiver1 = User.new.clone_with_profile if mem_subscriber.equal?( mem_caregiver1) # clone if same object
      else
        # nothing changed
      end
    end
    _user = (caregiving_subscriber? ? subscriber : mem_caregiver1)
    #
    # QUESTION: What happens when
    #   * subscriber == caregiver
    #   * caregiver position changed from elsewhere
    self.mem_caregiver1_options ||= (_user.options_for_senior( senior) || RolesUsersOption.new( :position => 1))
    _user
  end

  def caregiver1=(arg)
    caregiving_subscriber? ? caregiver1 : apply_attributes_to_object( arg, caregiver1)
  end

  def caregiver2
    # 
    #  Sat Jan 29 00:32:43 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4119
    #   * pick up the most recent one (sort b <> a) if multiple roles exist for some reason
    self.mem_caregiver2 ||= ( (users.select {|user| user.caregiver_position_for(senior) == 2}.sort {|a,b| b.created_at <=> a.created_at }.first) || User.new.clone_with_profile)
    _user = mem_caregiver2
    self.mem_caregiver2_options ||= (_user.options_for_senior( senior) || RolesUsersOption.new( :position => 2))
    # self.no_caregiver_2 = (self.mem_caregiver2.blank? || self.mem_caregiver2.nothing_assigned?)
    _user
  end

  def caregiver2=(arg)
    apply_attributes_to_object( arg, caregiver2)
  end

  def caregiver3
    # 
    #  Sat Jan 29 00:32:43 IST 2011, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/4119
    #   * pick up the most recent one (sort b <> a) if multiple roles exist for some reason
    self.mem_caregiver3 ||= ( (users.select {|user| user.caregiver_position_for(senior) == 3}.sort {|a,b| b.created_at <=> a.created_at }.first) || User.new.clone_with_profile)
    _user = mem_caregiver3
    self.mem_caregiver3_options ||= (_user.options_for_senior( senior) || RolesUsersOption.new( :position => 3))
    # self.no_caregiver_3 = (self.mem_caregiver3.blank? || self.mem_caregiver3.nothing_assigned?)
    _user
  end

  def caregiver3=(arg)
    apply_attributes_to_object( arg, caregiver3)
  end

  # 
  #  Thu Nov 11 02:55:34 IST 2010, ramonrails
  # Checked in any of the following situations
  #   * no_caregiver_1 is checked
  #   * subscriber is caregiver
  def hide_caregiver?( index = 1)
    if (1..3).include?( index)
      _caregiver = self.send("caregiver#{index}")
      #   * check subscriber status first
      #   * no_caregiver_1 will be forced by this anyways
      #   * then check the boolean on form
      ( (index == 1) && caregiving_subscriber? ) || (self.send("no_caregiver_#{index}") == true) || _caregiver.nothing_assigned?
    else
      false # force to show. this is incorrect call anyways
    end
  end

  def caregivers
    # when subscriber_is_caregiver, we still want to pick it as caregiver
    [caregiver1, caregiver2, caregiver3] # do not uniq.compact
  end

  # TODO: DRYness required here for methods

  def senior_attributes=(attributes)
    unless attributes.blank?
      self.senior = attributes
      #   * TODO: check if this is still required
      # attributes.each {|_key, _value| self.senior.send("#{_key}=", _value) }
      ["vip", "demo_mode"].each {|e| self.senior.send("#{e}=", ["1", "true", "yes"].include?( attributes[e] ) )}
    end
    senior
  end

  def subscriber_attributes=(attributes)
    unless attributes.blank? # || subscribed_for_self?
      self.subscriber = attributes
      # attributes.each {|_key, _value| self.subscriber.send("#{_key}=", _value) }
      # self.subscriber.skip_validation = self.skip_validation unless self.subscriber.blank?
    end
    subscriber
  end

  def caregiver1_attributes=(attributes)
    unless attributes.blank?
      self.caregiver1 = attributes
      # # equal? checks exact same object match. create a new caregiver1, if required
      # if caregiver1_required? && subscriber.equal?( caregiver1)
      #   self.subscriber_is_caregiver = false # switch off reference
      #   self.caregiver1 = nil
      # end
      # self.caregiver1 ||= User.new
      # attributes.each {|_key, _value| self.caregiver1.send("#{_key}=", _value) }
      # self.caregiver1.skip_validation = self.skip_validation unless self.caregiver1.blank?
    end
    caregiver1
  end

  def caregiver2_attributes=(attributes)
    unless attributes.blank?
      self.caregiver2 = attributes
      # attributes.each {|_key, _value| self.caregiver2.send("#{_key}=", _value) }
      # self.caregiver2.skip_validation = self.skip_validation unless self.caregiver2.blank?
    end
    caregiver2
  end

  def caregiver3_attributes=(attributes)
    unless attributes.blank?
      self.caregiver3 = attributes
      # attributes.each {|_key, _value| self.caregiver3.send("#{_key}=", _value) }
      # self.caregiver3.skip_validation = self.skip_validation unless self.caregiver3.blank?
    end
    caregiver3
  end

  def submitted?
    !submitted_at.blank? || !senior.status.blank? # timestamp is required to identify as "submitted"
  end

  # FIXME: DEPRECATED: use submitted? instead of this
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
    !paper_copy_submitted_on.blank? # paper_copy of the scubscriber agreement was submitted
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
      user.autofill_login unless user.blank? # || user.nothing_assigned?
      # #
      # # user_intake validation will fail if this is removed from here
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
    #
    # instantiate the user type if not already exists
    self.send("#{user_type}")
    # 
    # #
    # # roles_users_options for caregivers
    # # checkboxes for existence of caregivers
    # if user_type =~ /^senior$/
    #   self.subscriber_is_user = subscribed_for_self? # (subscriber_is_user.nil? || ["1", true].include?(subscriber_is_user))
    # 
    # elsif user_type =~ /^subscriber$/
    #   self.subscriber_is_caregiver = caregiving_subscriber? # (!subscriber_is_caregiver.nil? && ["1", true].include?( subscriber_is_caregiver))
    # 
    # elsif user_type =~ /^caregiver/
    #   _index = user_type[-1..-1].to_i
    #   _existing = self.send("no_caregiver_#{_index}") # check existing value
    #   self.send("no_caregiver_#{_index}=", ( _user.blank? || ["1", nil, true].include?(_existing) || _user.nothing_assigned? ))
    #   #
    #   # role options will be instantiated when called
    # end
  end

  def validate_user_type(user_type, _force = false)
    #
    # user object should have its own validations. just use them instead of imposing here
    user = self.send("#{user_type}".to_sym)
    if user.blank?
      errors.add_to_base( "#{user_type} cannot be blank") if _force == true
    else
      errors.add_to_base( "#{user_type}: " + user.errors.full_messages.join(', ')) unless (user.valid? || user.skip_validation)
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

  # def argument_to_object(arg)
  #   # User object
  #   if arg.is_a?(User)
  #     arg.profile_attributes = arg.profile.attributes unless arg.profile.blank?
  #     arg
  #   
  #   # attributes hash
  #   elsif arg.is_a?(Hash)
  #     user = User.new( arg)
  #     user.profile_attributes = arg[:profile_attributes] if arg.has_key?(:profile_attributes)
  #     user
  #   
  #   # anything else should just be discarded
  #   else
  #     nil
  #   end
  # end

  # ===========
  # = private =
  # ===========
  private
  
  def apply_attributes_to_object( _attributes, _instance)
    _hash = argument_to_attributes( _attributes)
    _hash.each { |k,v| _instance.send( "#{k}=", v) }
    _instance
  end

  def argument_to_attributes( _arg)
    if _arg.is_a?( User)
      _attributes = _arg.clone.attributes # .reject { |k,v| (k == 'id') || (k[-3..-1] == '_id') }
      _attributes["profile_attributes"] = _arg.profile.clone.attributes unless _arg.profile.blank? # .reject { |k,v| (k == 'id') || (k[-3..-1] == '_id') }
      _attributes
      
    elsif _arg.is_a?( Hash)
      _arg
      
    else
      {}
    end
  end

end
