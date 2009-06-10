class FunctionCaregiversByUserId < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
		create type caregiver_by_user AS (
		    pos   integer,
		    user_id integer,
		    login character varying(255),
			alert_type character varying(255),
			phone boolean,
			email boolean,
			text boolean,
			relationship character varying(255),
		    has_key boolean,
		    removed boolean,
		    active boolean
	  	);
	  	
		CREATE OR REPLACE FUNCTION caregivers_by_user_id(integer)
		RETURNS setof caregiver_by_user
		AS
		$$
			select roles_users_options.position as pos, users.id as user_id, users.login, alert_types.alert_type, alert_options.phone_active as phone, alert_options.email_active as email, alert_options.text_active as text, roles_users_options.relationship, roles_users_options.is_keyholder as has_key,roles_users_options.removed, roles_users_options.active from users, roles, roles_users, roles_users_options, alert_options, alert_types where roles.id = roles_users.role_id and (roles.authorizable_id = $1 and roles.authorizable_type = 'User' and roles.name = 'caregiver') and users.id = roles_users.user_id and roles_users.id = alert_options.roles_user_id and alert_options.alert_type_id = alert_types.id and roles_users_options.roles_user_id = roles_users.id order by roles_users_options.position;
		$$ 
		LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
