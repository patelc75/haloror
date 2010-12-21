class UpdateCaregiversByUserId2 < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
	  drop function caregivers_by_user_id(integer);
	  drop type caregiver_by_user;
	  
		create type caregiver_by_user AS (
		    roles_user_id integer,
		    first_name text,
		    last_name text,		    
		    user_id integer,
		    pos integer,
		    removed boolean,
		    active boolean,
			  phone boolean,
			  email boolean,
			  text boolean,
			  rel character varying(255),
		    key boolean
	  	);
	  	
		CREATE OR REPLACE FUNCTION caregivers_by_user_id(integer)
		RETURNS setof caregiver_by_user
		AS
		$$
      select roles_users.id as roles_user_id, profiles.first_name, profiles.last_name, users.id as user_id, roles_users_options.position as pos, roles_users_options.removed as removed, roles_users_options.active as active, roles_users_options.phone_active as phone, roles_users_options.email_active as email, roles_users_options.text_active as txt, roles_users_options.relationship as rel, roles_users_options.is_keyholder as key 
      from roles_users, users, roles_users_options, roles, profiles 
      where (roles_users.user_id = users.id and roles_users_options.roles_user_id = roles_users.id) 
      and roles.id = roles_users.role_id
      and profiles.user_id = users.id 
      and roles.authorizable_id = $1 
      order by pos; 
		$$ 
		LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
