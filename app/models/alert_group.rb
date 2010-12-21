class AlertGroup < ActiveRecord::Base
  #has_many :alert_types
  has_and_belongs_to_many :alert_types
  
  # 
  #  Tue Dec 21 21:53:43 IST 2010, ramonrails
  #   * dynamic methods for group types
  # Usage:
  #   * AlertGroup.battery
  #   * AlertGroup.critical
  class << self
    ["battery", "connectivity", "caution", "critical", "normal"].each do |_type|
      define_method "#{_type}".to_sym do
        find_by_group_type( _type)
      end
    end
  end
  
  def self.types_as_array
    all.collect(&:group_type)
  end
end
