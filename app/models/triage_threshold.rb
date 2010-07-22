class TriageThreshold < ActiveRecord::Base
  # these thresholds are defined for
  #   * defaults, identified by missing group_id
  #   * for specific group, identified by group_id
  belongs_to :group
  validates_numericality_of :battery_percent
    
  def after_initialize
    self.battery_percent ||= 100 # numericality is required. applies to data that has 0-100 % battery
    self.group_id ||= 0
  end
  
  def self.for_group_or_defaults( group = nil)
    group.blank? ? TriageThreshold.defaults : group.triage_thresholds
  end
  
  # return default set of values
  def self.defaults
    all.select {|e| e.group.blank? }
  end
  
  def group_name
    group.blank? ? '' : group.name
  end
  
  def group_name=(name)
    self.group = Group.find_or_create_by_name(name) unless name.blank?
  end
end
