class AlertType < ActiveRecord::Base
  has_many :alert_options
  belongs_to :alert_group
end
