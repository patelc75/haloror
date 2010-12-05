class RolesByUserIdFunction < ActiveRecord::Migration
  def self.up
	ddl = <<-eos	 
  create type role_row AS (
      role_id integer,   
	    role text,
	    group_or_user text
  	); 


	CREATE OR REPLACE FUNCTION roles_by_user_id(integer)
	RETURNS setof role_row
	AS
	$$
  SELECT roles.id as role_id, roles.name, groups.name
    from users, roles, roles_users, groups, profiles 
    where users.id = roles_users.user_id 
    and roles_users.role_id = roles.id 
    and roles.authorizable_type = 'Group' 
    and roles.authorizable_id = groups.id
    and users.id = profiles.user_id
    and users.id = $1
    order by roles.name;   
	$$ 
	LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end

