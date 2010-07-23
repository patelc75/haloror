class AddCreatedByIdToTriageAuditLogs < ActiveRecord::Migration
  def self.up
    add_column :triage_audit_logs, :created_by, :integer
    add_column :triage_audit_logs, :updated_by, :integer
  end

  def self.down
    remove_columns :triage_audit_logs, :created_by, :updated_by
  end
end
