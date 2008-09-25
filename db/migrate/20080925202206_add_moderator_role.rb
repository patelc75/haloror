class AddModeratorRole < ActiveRecord::Migration
  def self.up
    now = Time.now
    groups = Group.find(:all)
    groups.each do |group|
      Role.create(:name => 'moderator', :authorizable_type => 'Group', :authorizable_id => group.id, :updated_at => now, :created_at => now)
    end    
  end

  def self.down
    Role.delete(:conditions => "name = 'moderator'")
  end
end
