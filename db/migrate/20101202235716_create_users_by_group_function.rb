class CreateUsersByGroupFunction < ActiveRecord::Migration
  def self.up
	ddl = <<-eos	 
    drop function users_by_role_and_group(text, text);
    drop type user_by_role_and_group;	   
	  
	  create type user_by_role_and_group AS (
        user_id integer,   
  	    first_name text,
  	    last_name text,
        role_id integer,   
  	    role_name text,
  	    group_name text,
  	    status character varying(255),
  	    test_mode boolean,
  	    demo_mode boolean,
  	    vip boolean,
  	    created_at timestamp without time zone
    	);
    	 	
  	CREATE OR REPLACE FUNCTION users_by_role_and_group(text, text)
  	RETURNS setof user_by_role_and_group
  	AS
  	$$
    SELECT distinct users.id as user_id, profiles.first_name, profiles.last_name, roles.id as role_id, roles.name, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
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
  	
  	CREATE OR REPLACE FUNCTION users_by_group(text)
  	RETURNS setof user_by_role_and_group
  	AS
  	$$
    SELECT distinct users.id as user_id, profiles.first_name, profiles.last_name, roles.id as role_id, roles.name, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
      from users, roles, roles_users, groups, profiles 
      where users.id = roles_users.user_id 
      and roles_users.role_id = roles.id 
      and roles.authorizable_type = 'Group' 
      and roles.authorizable_id = groups.id
      and groups.name = $1
      and users.id = profiles.user_id
      order by roles.name, users.id;   
  	$$ 
  	LANGUAGE 'sql' STABLE;  

  	CREATE OR REPLACE FUNCTION users_by_role(text)
  	RETURNS setof user_by_role_and_group
  	AS
  	$$
    SELECT distinct (users.id) as user_id, profiles.first_name, profiles.last_name, roles.id as role_id, roles.name, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
      from users, roles, roles_users, groups, profiles 
      where users.id = roles_users.user_id 
      and roles_users.role_id = roles.id 
      and roles.name = $1
      and roles.authorizable_type = 'Group' 
      and roles.authorizable_id = groups.id
      and groups.name != 'safety_care'
      and users.id = profiles.user_id
      order by groups.name, users.id;   
  	$$ 
  	LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
