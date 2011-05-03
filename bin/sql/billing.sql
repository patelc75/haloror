-- Installed users ordered by state for jill ------------------------------------------------------------------------
SELECT distinct (users.id) as user_id, profiles.first_name, profiles.last_name, profiles.city, profiles.state, profiles.zipcode, profiles.home_phone, profiles.cell_phone, users.email, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
  from users LEFT OUTER JOIN profiles ON users.id = profiles.user_id, roles, roles_users, groups 
  where users.id = roles_users.user_id 
  and roles_users.role_id = roles.id 
  and roles.name = 'halouser'
  and roles.authorizable_type = 'Group' 
  and roles.authorizable_id = groups.id
  and groups.name != 'safety_care'
  and status = 'Installed' and demo_mode != true
  order by profiles.state asc, users.created_at desc
  limit 1000;         

-- Dealers aka admins (left out group.name column so only unique rows would be returned) ------------------------------------------------------------------------
SELECT distinct (users.id) as user_id, profiles.first_name, profiles.last_name, profiles.city, profiles.state, profiles.zipcode, profiles.home_phone, profiles.cell_phone, users.email, users.created_at
  from users LEFT OUTER JOIN profiles ON users.id = profiles.user_id, roles, roles_users, groups 
  where users.id = roles_users.user_id 
  and roles_users.role_id = roles.id 
  and roles.name = 'admin'
  and roles.authorizable_type = 'Group' 
  and roles.authorizable_id = groups.id
  and groups.name != 'safety_care'
  and users.email not like 'mikeb@mtsl.com'
  and users.email not like 'bhydrick@halomonitoring.com'
  and users.email not like 'chirag@halomonitoring.com'
  and users.email not like 'cmorris@halomonitoring.com'
  and users.email not like 'lhardy@halomonitoring.com'
  order by users.created_at desc
  limit 1000;                        
                      
-- Caregivers of installed or pending users (derived from caregivers_by_user_id Pg function)     
select users.email, profiles.first_name, profiles.last_name, users.id as user_id, roles_users_options.position as pos, roles_users_options.removed as removed, roles_users_options.active as active, roles_users_options.phone_active as phone, roles_users_options.email_active as email, roles_users_options.text_active as txt, roles_users_options.relationship as rel, roles_users_options.is_keyholder as key 
       from roles_users, users, roles_users_options, roles, profiles 
       where (roles_users.user_id = users.id and roles_users_options.roles_user_id = roles_users.id) 
       and roles.id = roles_users.role_id
       and profiles.user_id = users.id 
       and roles.authorizable_id in (select user_id from users_by_role_and_group('halouser', 'safety_care')) and users.email != 'no_email@halomonitoring.com' and users.email != 'noemail@halomonitoring.com' and users.email != 'no-email@halomonitoring.com' and users.email not like 'no-email__@halomonitoring.com' limit 1000;

-- Sort feature in Invoice - by Group, by Installed date, by Termination date -----------------------------
-- (psql -F ',' -A haloror > (run the query) > \o outputfile.csv > (use mutt to email)---------------------
select 
(select group_or_first_name from roles_by_user_id(invoices.user_id) where role = 'halouser' and group_or_first_name != 'safety_care' limit 1) as group,
profiles.first_name, profiles.last_name, users.demo_mode,
invoices.*
from invoices, users, profiles
where users.id = invoices.user_id
and (cancelled_date > now() - interval '1 month' or cancelled_date is null)
and profiles.user_id = users.id;                  


