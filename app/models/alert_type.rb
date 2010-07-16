class AlertType < ActiveRecord::Base
  has_many :alert_options
  #belongs_to :alert_group
  has_and_belongs_to_many :alert_groups
  #has_many :events
  
  def self.types_as_array
    all.collect(&:alert_type)
  end
end
