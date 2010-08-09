class AddWarningHoursToTriageThreshold < ActiveRecord::Migration
  def self.up
    add_column :triage_thresholds, :attribute_warning_hours, :integer
    add_column :triage_thresholds, :approval_warning_hours, :integer
    
    # update data as well
    failure_threshold = { "normal" => 0, "caution" => 3, "abnormal" => 4, "warning" => 0} # thresholds for each type of alert
    ["normal", "caution", "abnormal"].each do |type|
      # either select or create to get a row
      row = ( TriageThreshold.defaults.select {|e| e.status == type && e.group.blank? }.first or TriageThreshold.create( :status => type) )
      row and row.update_attributes( {
        :mgmt_query_count         => 4,
        :mgmt_query_failed_count  => failure_threshold[ type],
        :mgmt_query_delay_span    => (6.hours + 7.minutes).to_i,
        :attribute_warning_hours  => 48,
        :approval_warning_hours   => 4
      }) # update attributes
    end
    
  end

  def self.down
    remove_columns :triage_thresholds, :attribute_warning_hours, :approval_warning_hours
  end
end
