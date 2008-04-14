class AlertGroup < ActiveRecord::Base
  #has_many :alert_types
  has_and_belongs_to_many :alert_types
end
