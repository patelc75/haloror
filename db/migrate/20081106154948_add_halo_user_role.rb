class AddHaloUserRole < ActiveRecord::Migration
  def self.up
    halouser_role = Role.find_by_name('halouser')
    unless halouser_role
      now = Time.now
      groups = Group.find(:all)
      groups.each do |group|
        Role.create(:name => 'halouser', 
                    :authorizable_type => 'Group', 
                    :authorizable_id => group.id,
                    :created_at => now,
                    :update_at => now)
      end
    end
  end

  def self.down
  end
end
