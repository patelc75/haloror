class AlertGroup < ActiveRecord::Base
  has_many :alert_types
end
