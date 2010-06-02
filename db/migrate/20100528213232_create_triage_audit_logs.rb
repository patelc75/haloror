class CreateTriageAuditLogs < ActiveRecord::Migration
  def self.up
    create_table :triage_audit_logs do |t|
      t.column :id, :primary_key, :null => false
      t.column :user_id, :integer
      t.column :is_dismissed, :boolean
      t.column :description, :text

      t.timestamps
    end
  end

  def self.down
    drop_table :triage_audit_logs
  end
end
