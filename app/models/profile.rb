class Profile < ActiveRecord::Base
  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  belongs_to :user
  belongs_to :carrier
  belongs_to :emergency_number
end
