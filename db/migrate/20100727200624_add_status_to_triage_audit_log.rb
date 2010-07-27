class AddStatusToTriageAuditLog < ActiveRecord::Migration
  def self.up
    add_column :triage_audit_logs, :status, :string
  end

  def self.down
    remove_column :triage_audit_logs, :status
  end
end
