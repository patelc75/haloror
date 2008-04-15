class Profile < ActiveRecord::Base
  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  belongs_to :user
  belongs_to :carrier
end
