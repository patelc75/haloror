class AddGroupIdToSystemTimeouts < ActiveRecord::Migration
  def self.up
  	add_column :system_timeouts,:group_id,:integer
  	@group = Group.find_by_name('default') || Group.create(:name => 'default')
  	unless SystemTimeout.count(:all) >= 2
  		SystemTimeout.create(:mode => 'dialup',:gateway_offline_timeout_sec => 21600,:device_unavailable_timeout_sec => 21900 ,:strap_off_timeout_sec => 25200,:critical_event_delay_sec =>'120 seconds' ,:battery_reminder_two_sec => 7200 ,:battery_reminder_three_sec => 14400,:group_id => @group.id)
  		SystemTimeout.create(:mode => 'ethernet',:gateway_offline_timeout_sec => 1200,:device_unavailable_timeout_sec => 300 ,:strap_off_timeout_sec => 3600,:critical_event_delay_sec =>'120 seconds' ,:battery_reminder_two_sec => 7200 ,:battery_reminder_three_sec => 14400,:group_id => @group.id)
  	else
  		SystemTimeout.find(:all).each do |st|
  			st.update_attributes(:group_id => @group.id)
  		end
  	end
  	
  end

  def self.down
  	remove_column :system_timeouts,:group_id
  end
end
