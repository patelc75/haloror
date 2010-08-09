class Panic < CriticalDeviceAlert
  set_table_name('panics')

  # trigger
  # we just need it for this event. Not critical_device_alert.rb super class
  def after_save
    if (user = User.find(user_id))
      user.last_panic_id = id # buffer for last panic row related to this user
      # https://redmine.corp.halomonitor.com/issues/3215
      #   Ready for Install > Installed (green) is automatically transitioned
      #   Check for panic button test (must occur after the install date)
      auto_install = ((user.status == User::STATUS[:install_pending]) && (Time.now > user.updated_at))
      user.status = User::STATUS[:installed] if auto_install
      user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
      # add a row to triage audit log
      #   cyclic dependency is not created. update_withut_callbacks is used in triage_audit_log
      attributes = {
        :user         => user,
        :is_dismissed => user.last_triage_status,
        :status       => User::STATUS[:installed],
        :created_by   => user.id,
        :updated_by   => user.id,
        :description  => "Automatically transitioned from 'Ready to Insall' state to 'Installed' state by 'Panic button test'"
      }
      TriageAuditLog.create( attributes)
      # explicitly send email to admin. tables are saved without callbacks
      UserMailer.deliver_user_installation_alert( user)
    end
  end

  def to_s
    "#{user.name} panicked at #{UtilityHelper.format_datetime(timestamp, user)}"
  end

  def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{UtilityHelper.format_datetime(timestamp, user)}" +
    "\n\nA Halo operator will be handling the event immediately.\n\n" +
    "Sincerely, Halo Staff"
  end
end