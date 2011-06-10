class Panic < CriticalDeviceAlert
  set_table_name('panics')

  # trigger

  # WARNING: needs testing
  def before_save
    begin
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
    rescue
      true # no matter what, execute critical_device_event_observer.after_save
    end
  end

  # we just need it for this event. Not critical_device_alert.rb super class
  # * runs after the CriticalDeviceAlert.after_save
  def after_save
    begin
      # https://redmine.corp.halomonitor.com/issues/3215
      #
      unless user.blank?
        # 
        #  Wed Feb  9 23:26:29 IST 2011, ramonrails
        #   * this is the panic 'timestamp'
        #   * we do not want any difference at all between timestamp in panic & user intake
        # 
        #  Thu Feb 10 23:17:52 IST 2011, ramonrails
        #   * https://redmine.corp.halomonitor.com/issues/4180
        #   * tiemstamp may really not be the recent one. We need Time.now
        _time_now = Time.now
        #
        # buffer for last panic row related to this user
        user.update_attribute( :last_panic_id, id) # no validations
        #   * this is only for cucumber purpose
        if user.has_caregivers.any?(&:raises_exception?)
          raise "Custom exception for BDD tests only" # WARNING: this will not send emails until exception handling is added here
        end
        #
        # 
        # "Ready to Bill" state if panic is
        #   * after "Desired Installation Date"
        #   * senior is member of safety care, but in test mode (partial test mode)
        #   * only apply "ready to bill" state when current state is any of
        #     * Ready to Install or Install Overdue
        #   * "Installed" means, panic button was ok. user was "Bill"ed by human action
        _allowed_states = [User::STATUS[:install_pending], User::STATUS[:overdue]]
        if !user.desired_installation_date.blank? && (_time_now > user.desired_installation_date) && _allowed_states.include?( user.status.to_s)
          # 
          #  Fri Dec 17 21:01:27 IST 2010, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/3891
          if user.order_placed_online?
            # transition the user from "Ready to Install" => "Ready to Bill"
            #   * We need "bill" state when order was placed online
            if user.subscription_successful?
              #   * already "billed". we can simply go to "Installed" state
              user.update_attribute( :status, User::STATUS[:installed]) # "Installed"
            else
              user.update_attribute( :status, User::STATUS[:bill_pending]) # "Ready to bill". no validations
            end
          else
            #   * just mark the user "Installed", when created directly from user intake
            user.update_attribute( :status, User::STATUS[:installed]) # "Installed"
          end
          # # 
          # #  Tue Nov 23 00:48:30 IST 2010, ramonrails
          # #   * Pro rata is charged from the date we received panic button after 
          # user.user_intakes.first.update_attribute( :panic_received_at, _time_now) unless user.user_intakes.blank?
          #
          # add triage_audit_log with a message
          _message = "Automatically transitioned from 'Ready to Insall' to 'Ready to Bill' state at 'Panic button'"

          # 
          #  Wed Dec  1 03:36:39 IST 2010, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/3786
          #   * if subscription was already charged, mark user "installed"
        elsif (user.status.to_s == User::STATUS[:bill_pending]) && user.subscription_successful?
          user.update_attribute( :status, User::STATUS[:installed]) # "Installed"
          # # 
          # #  Tue Nov 23 00:48:30 IST 2010, ramonrails
          # #   * Pro rata is charged from the date we received panic button after 
          # user.user_intakes.first.update_attribute( :panic_received_at, _time_now) unless user.user_intakes.blank?
          #
          # add triage_audit_log with a message
          _message = "Automatically transitioned from any existing state to 'Installed' state at 'Panic button' because subscription started before panic event."
        end
        # 
        #  Tue Nov 23 00:48:30 IST 2010, ramonrails
        #   * Pro rata is charged from the date we received panic button after 
        #  Fri Dec 17 21:03:40 IST 2010, ramonrails
        #   * This is common method call for "if" conditions above
        unless user.user_intakes.blank?
          _intake = user.user_intakes.first
          # 
          #  Fri Feb 11 00:48:03 IST 2011, ramonrails
          #   * https://redmine.corp.halomonitor.com/issues/4181
          #   * we need panic_received_at and installed_at to reflect the actual timestamp
          #   * we cannot however switch the status to "Installed" as we want a concurrent "Ready to Bill" status
          # if panic < desired 
          #   panic_received_at is not updated and stays blank
          # elsif (panic > desired or desired.blank?)
          if _intake.installation_datetime.blank? || ( _time_now > _intake.installation_datetime )
            #   only the first panic updates panic_received_at, ignore subsequent panics
            if _intake.panic_received_at.blank?
              _intake.update_attribute( :panic_received_at, _time_now)
              #   send "<halouser> installed" email" 
              user.notify_about_installation
              # 
              #   update User.installed_at
              #  Tue May 24 23:08:25 IST 2011, ramonrails
              #   * https://redmine.corp.halomonitor.com/issues/4486
              #   * Installed at should not be updated when panic button is sent before "Ready for Approval" state
              #   * status.blank? means 'Not Submitted'
              user.update_attribute( :installed_at, _time_now) unless user.status.blank?
              # 
              # make all caregivers active
              #  Fri Feb  4 01:06:31 IST 2011, ramonrails
              #   * https://redmine.corp.halomonitor.com/issues/4147
              # all caregivers are active now
              user.has_caregivers.each { |e| e.set_active_for( user, true) }
              # Installed timestamp in the "Status" column of Single Row User Intake
              #   * updated in _user_intake_row.html.erb
              #
              # Completely disable test mode (User.test_mode = false)
              # 
              #  Fri Feb  4 22:31:15 IST 2011, ramonrails
              #   * https://redmine.corp.halomonitor.com/issues/4152
              #   * make user out of test mode here
              user.test_mode = false
              user.send( :update_without_callbacks)
            end
          end
          # # 
          # #  Fri Jan 28 02:15:27 IST 2011, ramonrails
          # #   * https://redmine.corp.halomonitor.com/issues/4111#note-7
          # #   * update the Panic.after_save, only store the first panic after installation_datetime, not every subsequent panic
          # if _intake.installation_datetime.blank?
          #   # Installation date time blank?
          #   ## First panic stored
          #   ## Subsequent panics do not over-write the first stored one
          #   _intake.update_attribute( :panic_received_at, _time_now) if _intake.panic_received_at.blank?
          # 
          # elsif _intake.panic_received_at.blank? || (_intake.panic_received_at < _intake.installation_datetime)
          #   # Installation date time given?
          #   ## First panic after the timestamp, is stored. Overwriting any existing one that might have existed before the timestamp
          #   ## Subsequent panics do not overwrite the existing stored one
          #   _intake.update_attribute( :panic_received_at, _time_now)
          # end
        end

        #
        # add to triage audit log with a message
        if defined?( _message) && !_message.blank?
          #
          # add a row to triage audit log
          #   cyclic dependency is not created. update_withut_callbacks is used in triage_audit_log
          attributes = {
            :user         => user,
            :is_dismissed => user.last_triage_status,
            :status       => user.status,
            :created_by   => user.id,
            :updated_by   => user.id,
            :description  => _message
          }
          TriageAuditLog.create( attributes)
        end

        #  Wed Nov  3 23:33:00 IST 2010, ramonrails 
        #   Old logic: "Installed" state can only be achieved by manual human action by clicking "Bill" in user intake
        #   shifted now to user_intake.rb
        # #  
        # #   Ready for Install > Installed (green) is automatically transitioned
        # #   Check for panic button test (must occur after the install date)
        # auto_install = ((user.status == User::STATUS[:install_pending]) && (_time_now > user.desired_installation_date))
        # if auto_install
        #   user.status = User::STATUS[:installed]
        #   #
        #   # explicitly send email to group admins, halouser, caregivers. tables are saved without callbacks
        #   [ user,
        #     user.user_intakes.collect(&:caregivers),
        #     user.user_intakes.collect(&:group).flatten.uniq.collect(&:admins)
        #   ].flatten.uniq.each do |_user|
        #     UserMailer.deliver_user_installation_alert( _user)
        #   end
        # end
        #
        #  Wed Nov  3 23:34:26 IST 2010, ramonrails 
        #   used update_attribute with validation skipping instead
        # user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
        #  
        #  Wed Nov  3 23:37:05 IST 2010, ramonrails 
        #   user is already a member when partial test mode was activated
        # user.is_halouser_of( Group.safety_care!) # user should also be opted in to call center
      end
      #
      # ramonrails: Thu Oct 14 02:05:21 IST 2010
      #   return TRUE to continue executing further callbacks, if any
      true
    rescue Exception => e
      # 
      #  Wed Feb  9 23:16:17 IST 2011, ramonrails
      #   * at least send an email about this error
      CriticalMailer.deliver_monitoring_failure( "Technical exception #{e}", self)
      true # no matter what, execute critical_device_event_observer.after_save
    end
  end

  def to_s
    "#{user.name} panicked on #{UtilityHelper.format_datetime(timestamp, user)}"
  end  
  
  def to_s_short
   "PANIC #{user.name}" 
  end

  def email_body
    "Hello,\nWe detected that #{user.name} pressed the panic button on #{UtilityHelper.format_datetime(timestamp, user)}" +
    "\n\nA Halo operator will be handling the event immediately.\n\n" +
    "- Halo Staff"
  end

  def can_map?
    self.respond_to?(:lat) && self.respond_to?(:long) # && !lat.blank? && !long.blank?
  end

  def coordinates
    if can_map?
      _return = [lat, long].compact.join(',')
      _return = nil if _return.blank?
    end
  end
  
  def location
    _location = coordinates
    if _location.blank?
      _location = (user.blank? ? 'U.S.A.' : (user.location || 'U.S.A.'))
    end
  end
end