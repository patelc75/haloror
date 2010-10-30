class Panic < CriticalDeviceAlert
  set_table_name('panics')

  # trigger

  # WARNING: needs testing
  def before_save
    # debugger
    #
    # test-mode status is redundant here for the purpose reporting etc...
    #
    # ramonrails Thu Oct 14 05:14:06 IST 2010
    #   lately, we have test_mode working as follows
    #   * user is considered in test mode when user.test_mode == true
    #   * when user goes into test mode
    #     * membership of safety_care is opted
    #     * caregivers are set away
    # user = User.find(user_id) # not required. user is already assigned here
    self.test_mode = user.test_mode? unless user.blank?
    #
    # ramonrails: Thu Oct 14 01:56:19 IST 2010
    # CHANGED: ** do not ** return a false
    #   returning false will abort any further execution of calbacks, or this save
    #   above code was un-intentionally returning false in some cases
    true # continue execution. returning false would not save the record
  end

  # we just need it for this event. Not critical_device_alert.rb super class
  # * runs after the CriticalDeviceAlert.after_save
  def after_save
    # debugger
    # https://redmine.corp.halomonitor.com/issues/3215
    #
    unless user.blank?
      #
      # buffer for last panic row related to this user
      user.last_panic_id = id
      #
      # 
      # "Ready to Bill" state if panic is after "Desired Installation Date" and User.test_mode != true
      (user.status = User::STATUS[:bill_pending]) if ((Time.now > user.created_at) && (user.test_mode != true))
      #
      #   Ready for Install > Installed (green) is automatically transitioned
      #   Check for panic button test (must occur after the install date)
      auto_install = ((user.status == User::STATUS[:install_pending]) && (Time.now > user.updated_at))
      if auto_install
        # debugger
        user.status = User::STATUS[:installed]
        #
        # add a row to triage audit log
        #   cyclic dependency is not created. update_withut_callbacks is used in triage_audit_log
        attributes = {
          :user         => user,
          :is_dismissed => user.last_triage_status,
          :status       => user.status,
          :created_by   => user.id,
          :updated_by   => user.id,
          :description  => "Automatically transitioned from 'Ready to Insall' state to 'Installed' state by 'Panic button test'"
        }
        TriageAuditLog.create( attributes)
        #
        # explicitly send email to group admins, halouser, caregivers. tables are saved without callbacks
        [ user,
          user.user_intakes.collect(&:caregivers),
          user.user_intakes.collect(&:group).flatten.uniq.collect(&:admins)
        ].flatten.uniq.each do |_user|
          UserMailer.deliver_user_installation_alert( _user)
        end
      end
      #
      user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
      user.is_halouser_of( Group.safety_care!) # user should also be opted in to call center
    end
    #
    # ramonrails: Thu Oct 14 02:05:21 IST 2010
    #   return TRUE to continue executing further callbacks, if any
    true
  end

  def to_s
    "#{user.name} panicked on #{UtilityHelper.format_datetime(timestamp, user)}"
  end

  def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{UtilityHelper.format_datetime(timestamp, user)}" +
    "\n\nA Halo operator will be handling the event immediately.\n\n" +
    "- Halo Staff"
  end
end