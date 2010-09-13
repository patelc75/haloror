class AddFieldsToTriageThreshold < ActiveRecord::Migration
  def self.up
    add_column :triage_thresholds, :mgmt_query_count, :integer
    add_column :triage_thresholds, :mgmt_query_failed_count, :integer
    add_column :triage_thresholds, :mgmt_query_delay_span, :integer

    # update data as well
    failure_threshold = { "normal" => 0, "caution" => 3, "abnormal" => 4} # thresholds for each type of alert
    ["normal", "caution", "abnormal"].each do |type|
      if !( row = TriageThreshold.defaults.select {|e| e.status == type && e.group.blank? }.first )
        row = TriageThreshold.create( :status => type)
      end
      row.update_attributes( { :mgmt_query_count => 4, :mgmt_query_failed_count => failure_threshold[ type], :mgmt_query_delay_span => (6.hours + 7.minutes).to_i }) if row # update attributes
    end
  end

  def self.down
    remove_columns :triage_thresholds, :mgmt_query_count, :mgmt_query_failed_count, :mgmt_query_delay_span
  end
end
