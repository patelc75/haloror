/* All users grouped by states (no conditions) */	
select count (*),status from users group by status;

/* All users grouped by demo_mode */	
select demo_mode, count(*) from users group by demo_mode;

/* Individual non-demo users not in an installed state */	
select id, status from users where demo_mode = false and status is not null and status != 'Installed' order by status;

/* Individual installed users mapped to a device */ 	
select distinct users.id, users.status, users.demo_mode from users, devices_users, devices where users.status is not null and users.status = 'Installed' and users.id = devices_users.user_id order by users.status;

/* Individual non-installed users mapped to a device */	
select distinct users.id, users.status, users.demo_mode from users, devices_users, devices where users.status is not null and users.status != 'Installed' and users.id = devices_users.user_id order by users.status;

/* "Pg function users_by_role_and_group() to show all halousers for safety_care group for example" */
select * from users_by_role_and_group('halouser', 'ems');
