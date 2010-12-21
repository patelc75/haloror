class CreateAlertOptionsByUserId < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
		create type alert_options_by_user AS (
		    roles_user_id integer,
		    first_name text,
		    last_name text,		    
		    user_id integer,
		    alert_type text,		    
			  phone boolean,
			  email boolean,
			  text boolean
	  	);
	  	
		CREATE OR REPLACE FUNCTION alert_options_by_user_id(integer)
		RETURNS setof alert_options_by_user
		AS
		$$
      select roles_users.id as roles_user_id, profiles.first_name, profiles.last_name, users.id as user_id, alert_types.alert_type, alert_options.phone_active as phone, alert_options.email_active as email, alert_options.text_active as txt
      from roles_users, users, alert_options, roles, alert_types, profiles
      where (roles_users.user_id = users.id and alert_options.roles_user_id = roles_users.id) 
      and roles.id = roles_users.role_id 
      and alert_options.alert_type_id = alert_types.id
      and profiles.user_id = users.id
      and roles.authorizable_id = $1;  
		$$ 
		LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
