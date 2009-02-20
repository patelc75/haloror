class CreateSuperAdminRole < ActiveRecord::Migration
  def self.up
    now = Time.now
    halo_group = Group.create(:name => 'halo', :created_at => now, :updated_at => now)
    administrator_roles = Role.find(:all, :conditions => "name = 'administrator' ", :order => 'id asc')
    
    super_admin = administrator_roles.first
    
    if (!super_admin.nil?)
      super_admin.name = 'super_admin'
      super_admin.authorizable_type = 'Group'
      super_admin.authorizable_id = halo_group.id
      super_admin.save!
	end
	
    administrator_roles.each do |role|
      role.roles_users.each do |roles_user|
        roles_user.role_id = super_admin.id
        roles_user.save!
      end
      if role.id != super_admin.id
        Role.delete(role)
      end
    end
   
  end

  def self.down
    
  end
end
