class TriageAuditLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updator, :class_name => "User", :foreign_key => "updated_by"

  named_scope :action_required, :conditions => { :is_dismissed => true }
  named_scope :few, lambda {|*args| { :limit => ( args.flatten.first || 5) }}
  named_scope :recent_on_top, :order => "created_at DESC"
  named_scope :where_status, lambda {|arg| { :conditions => { :status => arg} }}
  
  def self.latest
    first( :order => "created_at DESC")
  end
  
  # WARNING: test coverage required
  def before_save
    # if the "status" is blank for this row, pick the last one
    self.status = user.last_triage_audit_log.status if ( status.blank? && user && user.last_triage_audit_log )
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

  def status_color
    'white' # user.status_button_color
  end
end
