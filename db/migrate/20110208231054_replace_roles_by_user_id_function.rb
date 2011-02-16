class ReplaceRolesByUserIdFunction < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
	drop function roles_by_user_id(integer); 
	drop type role_row;   

  create type role_row AS (
      role_id integer,   
	    role text,
	    group_or_first_name text,  
	    last_name text
  	); 

	CREATE OR REPLACE FUNCTION roles_by_user_id(integer)
	RETURNS setof role_row
	AS
	$$
  SELECT roles.id as role_id, roles.name, 
  CASE 
   WHEN (roles.authorizable_type = 'Group')
    THEN (select name from groups where id = roles.authorizable_id)
   WHEN (roles.authorizable_type = 'User')  
    THEN (select profiles.first_name from users, profiles where users.id = roles.authorizable_id and users.id = profiles.user_id)
  END as group_or_user,
  CASE 
   WHEN (roles.authorizable_type = 'User')  
    THEN (select profiles.last_name from users, profiles where users.id = roles.authorizable_id and users.id = profiles.user_id)
  END as group_or_user
    from users, roles, roles_users, profiles 
    where users.id = roles_users.user_id 
    and roles_users.role_id = roles.id 
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

