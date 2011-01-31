class AddUsersByUserIntakeId < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
		create type user_by_user_intake_id AS (
		    user_id integer,
		    first_name text,
		    last_name text,		 
		    name text,		    
		    pos integer,
		    active boolean,
		    a_type text,
		    a_id integer,
		    activated_at timestamp without time zone,     
		    login text
	  	);

		CREATE OR REPLACE FUNCTION users_by_user_intake_id(integer)
		RETURNS setof user_by_user_intake_id
		AS
		$$
    select distinct roles_users.user_id, profiles.first_name, profiles.last_name, roles.name, roles_users_options.position as pos, roles_users_options.active as active, roles.authorizable_type as a_type, roles.authorizable_id as a_id, users.activated_at, users.login 
      from roles_users left outer join roles_users_options on roles_users.id = roles_users_options.roles_user_id, roles, users, profiles  
      where roles_users.user_id in (select users.id from users, profiles where users.id in (select user_id from user_intakes_users where user_intake_id = $1) and profiles.user_id = users.id) 
      and roles_users.user_id = users.id 
      and users.id = profiles.user_id
      and roles_users.role_id = roles.id
      order by roles_users_options.position asc, user_id;  
		$$ 
		LANGUAGE 'sql' STABLE;
    eos

    execute ddl
  end

  def self.down
  end
end   


