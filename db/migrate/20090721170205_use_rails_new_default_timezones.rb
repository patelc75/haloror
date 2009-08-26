class UseRailsNewDefaultTimezones < ActiveRecord::Migration
 def self.up
    @users = User.all
    @users.each do |user|
      user.profile.time_zone = 'UTC' if user.profile.time_zone.blank?
      tz = TZInfo::Timezone.get(user.profile.time_zone) rescue TimeZone[user.profile.time_zone] || TimeZone['UTC']
      time_zone = if tz.is_a?(TZInfo::Timezone)
        linked_timezone = tz.instance_variable_get('@linked_timezone')
        name = linked_timezone ? linked_timezone.name : tz.name
        TimeZone::MAPPING.index(name)
      else
        tz.name
      end
      user.profile.update_attribute(:time_zone, time_zone) unless time_zone == user.profile.time_zone
    end unless @users.empty?
  end
 
  def self.down
  end

end
