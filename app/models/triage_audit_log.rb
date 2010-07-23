class TriageAuditLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updator, :class_name => "User", :foreign_key => "updated_by"

  # cache trigger
  # saves the latest triage_audit_log status in users table
  def after_save
    if (user = User.find(user_id))
      user.last_triage_audit_log_id = id
      user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
    end
    # User.update(user_id, {:last_triage_audit_log_id => id})
  end
  
  def user_name
    user.blank? ? '' : user.name
  end
  
end
