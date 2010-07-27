class TriageAuditLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updator, :class_name => "User", :foreign_key => "updated_by"

  # WARNING: test coverage required
  def before_save
    # if the "status" is blank for this row, pick the last one
    self.status = user.last_triage_audit_log.status if ( status.blank? && !user.blank? )
  end

  # cache trigger
  # saves the latest triage_audit_log status in users table
  def after_save
    unless user.blank? # WARNING: test coverage required
      user.last_triage_audit_log_id = id
      user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
    end
    # User.update(user_id, {:last_triage_audit_log_id => id})
  end
  
  def user_name
    user.blank? ? '' : user.name
  end

  # status color as defined in UserIntake::STATUS_COLOR
  def status_color
    UserIntake.status_color( status)
  end
end
