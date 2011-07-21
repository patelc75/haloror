/* TO HELP DEBUG THE CONFIG > USER STATS PAGE */
 curl -v -k -H "Content-Type: text/xml" -d "<panic><device_id>1</device_id><duration_press>1000</duration_press><gw_timestamp>Mn Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>886</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "https://sdev.myhalomonitor.com/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 

--------- All users grouped by states (no conditions) -----------
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
select user_id from users_by_role('halouser') where status = 'Installed' and demo_mode != true order by vip desc, created_at;

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


select id, user_id, account_number, first_name, last_name from profiles where account_number is not null order by id desc;
select id from users order by id desc;

select users.id as user_id, profiles.first_name, profiles.last_name, devices_users.device_id, devices.serial_number from users
left outer join devices_users on users.id = devices_users.user_id, devices, profiles
where users.id = profiles.user_id
and devices.id = devices_users.device_id 
and users.status = $1
order by users.id asc; 

select * from users where status = 'Installed';

select * from alert_options_by_user_id(5);
select * from users_by_role('halouser');
select id, status from users where id in (641);
select id, status from users where status is not null;
update users set status = 'Ready to Install' where id in (1159, 937);
update users set status = 'Cancelled' where id in (641);

update users set status = 'Installed' where id in (1207, 1209, 1222, 1167);
update users set vip = false where id in (1222, 1209);
update users set demo_mode = false where id in (1222);


select users.id as user_id, profiles.first_name, profiles.last_name, devices_users.device_id, devices.serial_number from users
left outer join devices_users on users.id = devices_users.user_id, devices, profiles
where users.id = profiles.user_id
and devices.id = devices_users.device_id 
and users.status = 'Installed'
order by users.id asc;

select distinct users.id from users
left outer join devices_users on users.id = devices_users.user_id, devices, profiles
where users.id = profiles.user_id
and devices.id = devices_users.device_id 
and users.status = 'Installed'
order by users.id asc;

/* refs #3740 pull all gateways that are in ethernet mode */
select * from devices 
where id in (select device_id from access_mode_statuses where mode = 'ethernet') 
and  id in (select id from devices where serial_number like 'H2%');	
    	
select * from users_by_group('meridian') where demo_mode = false;
select * from users_by_role_and_group('halouser', 'meridian');
select * from users_by_role('halouser');


select user_id, first_name, last_name, group_name, status, test_mode, demo_mode, vip from users_by_role('halouser');

select count(*) from users where id in (select user_id from users_by_role('halouser') where status = 'Installed'); /* Installed Halousers*/
select count(*) from users where status = 'Installed';
select count(*) from users where id in (select user_id from users_by_role('halouser') where demo_mode = true); /* Demo Halousers*/
select count(*) from users where id in (select user_id from users_by_role('halouser')); /*Total Halousers */
select* from users_by_role('halouser');
select user_id from users_by_role('halouser') order by user_id;

select roles_users.*, roles.name from roles_users, roles where roles_users.role_id = roles.id and user_id = 19;

select users.id, profiles.first_name, profiles.last_name, users.demo_mode, users.vip, users.status, users.created_at from users, profiles where users.id = profiles.user_id order by id desc;

select user_id, first_name, last_name, group_name, test_mode, demo_mode, vip, created_at from users_by_role('halouser') where status = 'Installed' order by vip desc, created_at desc;

select * from events where user_id = 470 order by timestamp desc;

select orig.users.id, first_name, 
last_name, group_name, test_mode, demo_mode, vip, created_at 
from users_by_role('halouser') orig, devices_users, devices 
where status = 'Installed' 
order by vip desc, created_at desc;

          CASE WHEN first_name like 'C%' THEN 'C letter'
               WHEN first_name like 'a%' THEN 'a letter'
               ELSE 'other'
          END,
          
SELECT a,
          CASE WHEN a=1 THEN 'one'
               WHEN a=2 THEN 'two'
               ELSE 'other'
          END
    FROM test;

select user_id, first_name, last_name, group_name, test_mode, demo_mode, vip, created_at 
from users_by_role('halouser') 
where status = 'Installed' 
order by vip desc, created_at desc;

select *
from users_by_role('halouser') 
where status = 'Installed' 	
order by vip desc, created_at desc;

select * from users_by_role_and_group('halouser', 'safety_care');

/* show all "installed" users and all dtc users who have been shipped but not installed ----------------------------------------- */

select user_id, first_name, last_name, group_name, test_mode, demo_mode, vip, created_at 
from users_by_role('halouser') 
where status = 'Installed' 
order by user_id asc;    

select user_id, first_name, last_name, group_name, test_mode, demo_mode, vip, created_at 
 