class TriageThreshold < ActiveRecord::Base
  belongs_to :group
  validates_presence_of :group
  validates_numericality_of :battery_percent
  
  def group_name
    group.blank? ? '' : group.name
  end
  
  def group_name=(name)
    self.group = Group.find_or_create_by_name(name) unless name.blank?
  end
end
