class UpdateUsersByRole3 < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
    CREATE OR REPLACE FUNCTION users_by_role(text)
      RETURNS SETOF user_by_role_and_group AS
    $BODY$
        SELECT distinct users.id as user_id, profiles.first_name, profiles.last_name, profiles.city, profiles.state, profiles.zipcode, users.email, profiles.home_phone, profiles.cell_phone, profiles.birth_date, roles.id as role_id, roles.name, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
          from users, roles, roles_users, groups, profiles 
          where users.id = roles_users.user_id 
          and roles_users.role_id = roles.id 
          and roles.name = $1
          and roles.authorizable_type = 'Group' 
          and roles.authorizable_id = groups.id
          and users.id = profiles.user_id
          order by users.id;   
      	$BODY$
      LANGUAGE sql STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
