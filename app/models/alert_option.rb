class AlertOption < ActiveRecord::Base
  belongs_to :roles_user
  belongs_to :alert_type
end
