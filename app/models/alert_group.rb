class AlertGroup < ActiveRecord::Base
  #has_many :alert_types
  has_and_belongs_to_many :alert_types
  
  def self.types_as_array
    all.collect(&:group_type)
  end
end
