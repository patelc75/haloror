-- Ordered by state for jill ------------------------------------------------------------------------
      SELECT distinct (users.id) as user_id, profiles.first_name, profiles.last_name, profiles.city, profiles.state, profiles.zipcode, profiles.home_phone, profiles.cell_phone, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
        from users LEFT OUTER JOIN profiles ON users.id = profiles.user_id, roles, roles_users, groups 
        where users.id = roles_users.user_id 
        and roles_users.role_id = roles.id 
        and roles.name = 'halouser'
        and roles.authorizable_type = 'Group' 
        and roles.authorizable_id = groups.id
        and groups.name != 'safety_care'
        and status = 'Installed' and demo_mode != true
        order by profiles.state asc, users.created_at desc;  


-- Sort feature in Invoice - by Group, by Installed date, by Termination date -----------------------------
-- (psql -F ',' -A haloror > (run the query) > \o outputfile.csv > (use mutt to email)---------------------
select 
(select group_or_first_name from roles_by_user_id(invoices.user_id) where role = 'halouser' and group_or_first_name != 'safety_care' limit 1) as group,
profiles.first_name, profiles.last_name,
invoices.*
from invoices, users, profiles
where users.id = invoices.user_id
and profiles.user_id = users.id;