class ConvertNullGroups < ActiveRecord::Migration
  def self.up
    convert_group('halo') 
    convert_group('meridian')
  end

  def self.down
    
  end

  def self.convert_group(group_name)    
    group = Group.find(:first, :conditions => "name = '#{group_name}'")
    roles = Role.find(:all, :conditions => "authorizable_type IS NULL")
    roles.each do |role|
      RolesUser.find(:all, :conditions => "role_id = #{role.id}").each do |role_user|
        new_role = Role.find(:first, :conditions => "name = '#{role.name}' AND authorizable_id = #{group.id} AND authorizable_type = 'Group'")
        role_user.role_id = new_role.id
        role_user.save!
      end
    end
    Role.delete(roles)
  end

end
