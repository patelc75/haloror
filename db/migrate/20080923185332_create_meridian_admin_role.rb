class CreateMeridianAdminRole < ActiveRecord::Migration
  def self.up
    id = Group.find(:first, :conditions => "name = 'meridian'").id
    now = Time.now
    Role.create(:name => 'admin', :authorizable_type => 'Group', :authorizable_id => id, :created_at => now, :updated_at => now)
  end

  def self.down
  end
end
