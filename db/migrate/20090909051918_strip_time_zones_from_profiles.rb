class StripTimeZonesFromProfiles < ActiveRecord::Migration
  def self.up
    @users = User.all
    @users.each do |user|
      if !user.profile.nil?
        if !user.profile.time_zone.nil?
          time_zone = user.profile.time_zone.strip 
          user.profile.update_attribute(:time_zone, time_zone)
        end
      end
    end unless @users.empty?    
  end

  def self.down
  end
end