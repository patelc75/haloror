class CreateOperatorRole < ActiveRecord::Migration
    def self.up
    now = Time.now
    groups = Group.find(:all)
    groups.each do |group|
    r = Role.find(:first, :conditions => "name = 'operator' AND authorizable_type = 'Group' AND authorizable_id = #{group.id}")
      unless r
        Role.create(:name => 'operator', :authorizable_type => 'Group', :authorizable_id => group.id, :updated_at => now, :created_at => now)
      end    
    end
  end

  def self.down
    
  end
end
