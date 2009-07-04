class AlertOption < ActiveRecord::Base
  acts_as_audited
  belongs_to :roles_user
  belongs_to :alert_type
end
