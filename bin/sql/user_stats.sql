/* TO HELP DEBUG THE CONFIG > USER STATS PAGE */

/* All users grouped by states (no conditions) */	
select count (*),status from users group by status;

/* All users grouped by demo_mode */	
select demo_mode, count(*) from users group by demo_mode;

/* Individual non-demo users not in an installed state */	
select id, status from users where demo_mode = false and status is not null and status != 'Installed' order by status;

/* Installed non-demo halousers with first_name, last_name */
select users.id, users.vip, profiles.first_name, profiles.last_name, profiles.city, profiles.state, users.created_at 
from users, profiles 
where users.status = 'Installed' and demo_mode != true and users.id = profiles.user_id order by users.vip desc, users.created_at desc;

/* Installed users (not halousers) */
select users.id, users.vip, users.demo_mode, profiles.first_name, profiles.last_name, profiles.city, profiles.state, users.created_at 
from users, profiles 
where users.status = 'Installed' and users.id = profiles.user_id order by users.vip desc, users.created_at desc;

/* Installed halousers */
select user_id, first_name, last_name, demo_mode from users_by_role('halouser') where status = 'Installed' and demo_mode != true order by demo_mode desc, user_id;
select user_id from users_by_role('halouser') where status = 'Installed' and demo_mode != true order by demo_mode desc, user_id;

/* Individual installed users mapped to a device */ 	
select distinct users.id, users.status, users.demo_mode from users, devices_users, devices where users.status is not null and users.status = 'Installed' and users.id = devices_users.user_id order by users.status;

/* Individual non-installed users mapped to a device */	
select distinct users.id, users.status, users.demo_mode from users, devices_users, devices where users.status is not null and users.status != 'Installed' and users.id = devices_users.user_id order by users.status;

/* "Pg function users_by_role_and_group() to show all halousers for safety_care group for example" */
select * from users_by_role_and_group('halouser', 'ems');


select user_id, first_name, last_name, role_name, group_name, demo_mode, status from users_by_role('halouser') where status like '%ancelled%' order by demo_mode;
select distinct user_id, first_name, last_name, role_name, group_name, demo_mode, status from users_by_role('halouser') where demo_mode = true order by user_id;
select * from roles_by_user_id(1);

select user_id, first_name, last_name, role_name, group_name, demo_mode, status from users_by_role('halouser');
select count(*) from users_by_role('halouser');

/* Convert a set of user_ids to "Cancelled" */
select users.id, users.login, users.email, users.status, users.demo_mode, profiles.first_name, profiles.last_name from users, profiles where profiles.user_id = users.id and users.id in (269, 624, 667, 668, 687, 697, 708, 729, 738, 739, 740, 749, 754, 759, 781, 782, 787, 811, 973);
update users set status = 'Cancelled' where id in (269, 624, 667, 668, 687, 697, 708, 729, 738, 739, 740, 749, 754, 759, 781, 782, 787, 811, 973);

/* Convert a set of user_ids to "Installed" */
select users.id, users.login, users.email, users.status, users.demo_mode, users.vip, profiles.first_name, profiles.last_name 
from users
left outer join profiles on profiles.user_id = users.id 
where users.id in (404);
update users set status = 'Installed' where id in (404);

/* Set demo_mode = true for a set of user_ids */
select users.id, users.login, users.email, users.status, users.demo_mode, profiles.first_name, profiles.last_name from users, profiles where profiles.user_id = users.id and users.id in (163, 1146);
update users set demo_mode = true where id in (163, 1146);

/* Set vip = true for a set of user_ids */
select users.id, users.login, users.email, users.status, users.demo_mode, users.vip, profiles.first_name, profiles.last_name 
from users, profiles 
where profiles.user_id = users.id and users.id in (1065, 712, 688);
update users set vip = true where id in (1065, 712, 688);

/* test */
    SELECT distinct (users.id) as user_id, profiles.first_name, profiles.last_name, roles.id as role_id, roles.name, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
      from users, roles, roles_users, groups
      left outer join profiles on users.id = profiles.user_id
      where users.id = roles_users.user_id 
      and roles_users.role_id = roles.id 
      and roles.name = 'halouser'
      and roles.authorizable_type = 'Group' 
      and roles.authorizable_id = groups.id
      and groups.name != 'safety_care'
      order by groups.name, users.id;   


