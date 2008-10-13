class AddInstallerAndSalesPersonRoles < ActiveRecord::Migration
  def self.up
    now = Time.now
    groups = Group.find(:all)
    groups.each do |group|
      Role.create(:name => 'installer', :authorizable_type => 'Group', :authorizable_id => group.id, :updated_at => now, :created_at => now)    
      Role.create(:name => 'sales', :authorizable_type => 'Group', :authorizable_id => group.id, :updated_at => now, :created_at => now)    
    end
  end

  def self.down
    Role.delete(:all, :conditions => "name = 'sales'")
    Role.delete(:all, :conditions => "name = 'installer'")
  end
end
