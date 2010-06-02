class TriageAuditLog < ActiveRecord::Base
  belongs_to :user # , :class_name => "User", :foreign_key => "user_id"
  
  def after_save
    if (user = User.find(user_id))
      user.last_triage_audit_log_id = id
      user.save
    end
    # User.update(user_id, {:last_triage_audit_log_id => id})
  end
  
  def user_name
    user.blank? ? '' : user.name
  end
  
end
