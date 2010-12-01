class FunctionRolesForGroup < ActiveRecord::Migration
  def self.up
	ddl = <<-eos	  
  	create type user_by_role_and_group AS (
        user_id integer,   
  	    first_name text,
  	    last_name text,
        role_id integer,   
  	    role_name text,
  	    group_name text
    	);
  	
  	CREATE OR REPLACE FUNCTION users_by_role_and_group(text, text)
  	RETURNS setof user_by_role_and_group
  	AS
  	$$
      SELECT distinct users.id as user_id, profiles.first_name, profiles.last_name, roles.id as role_id, roles.name, groups.name
      from users, roles, roles_users, groups, profiles 
      where users.id = roles_users.user_id 
      and roles_users.role_id = roles.id 
      and roles.name = $1
      and roles.authorizable_type = 'Group' 
      and roles.authorizable_id = groups.id
      and groups.name = $2
      and users.id = profiles.user_id
      order by users.id;   
  	$$ 
  	LANGUAGE 'sql' STABLE;   
    eos
    
    execute ddl
  end

  def self.down
  end
end
