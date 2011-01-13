/* refs #3666 auto-increment safetycare account number */
select id, first_name, last_name, account_number from profiles where account_number is not null order by account_number desc;
select id, first_name, last_name, account_number from profiles where account_number = '1125' order by account_number desc;
update profiles set account_number = '1111' where id in (459, 405, 1085, 711, 1108, 34, 1094, 999, 552, 967, 980, 47, 158);
update profiles set account_number = NULL where id in (459, 405, 1085, 711, 1108, 34, 1094, 999, 552, 967, 980, 47, 158);
select id, first_name, last_name, account_number from profiles where id in (11, 459, 405, 1085, 711, 1108, 34, 1094, 999, 552, 967, 980, 47, 158);

/* refs #3740 pull all gateways that are in ethernet mode */
select * from devices 
where id in (select device_id from access_mode_statuses where mode = 'ethernet') 
and  id in (select id from devices where serial_number like 'H2%');	



scurl -v -k -H "Content-Type: text/xml" -d "<panic><device_id>26</device_id><duration_press>1000</duration_press><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>848</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "https://sdev.myhalomonitor.com:3000/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"
curl -v -H "Content-Type: text/xml" -d "<panic><device_id>26</device_id><duration_press>1000</duration_press><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><user_id>848</user_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></panic>" "http://sdev.myhalomonitor.com:3000/panics?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024"

drop function users_by_role_and_group(text, text);
drop function users_by_group(text);
drop function users_by_role(text);

drop type user_by_role_and_group;
    	
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

drop function roles_by_user_id(integer);
drop type role_row;

select roles_users.*, roles.name from roles_users, roles where roles_users.role_id = roles.id and user_id = 19;

select * from mgmt_cmds where timestamp > '2010-12-06' and timestamp < '2010-12-07';

select * from mgmt_cmds where device_id = 5877 and cmd_type = 'firmware_upgrade';/
delete from mgmt_cmds where id = 3081009;

select * from events where user_id = 292 order by timestamp desc;

select * from mgmt_queries where device_id = 330 order by timestamp_server desc limit 10;
select count(*) from users;

select * from caregivers_by_user_id(5);

select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server  as delay from falls where timestamp_call_center-timestamp_server > interval'5 minutes' order by id desc limit 100;

select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server  as delay from panics where ((timestamp_call_center-timestamp_server) > interval'5 minutes') order by id desc limit 100;

select id, user_id, timestamp, weight, weight_unit, battery, serial_number from weight_scales where user_id != 0 order by id desc;

select * from device_model_prices order by device_model_id;
update device_model_prices set device_model_id = 8 where device_model_id = 5;

curl -v -H "Content-Type: text/xml" -d "<fall><device_id>1</device_id><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><magnitude>60</magnitude><severity>12</severity><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><user_id>6</user_id></fall>" "http://localhost:3000/falls?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 

select emails.from, emails.mail from emails order by id desc limit 5;

select user_id, first_name, last_name, group_name, test_mode, demo_mode, vip, created_at 
from users_by_role('halouser') 
where status = 'Installed' 
order by vip desc, created_at desc;

select *
from users_by_role('halouser') 
where status = 'Installed' 	
order by vip desc, created_at desc;

select * from users_by_role_and_group('halouser', 'safety_care');

select users.id, users.login, users.status, users.demo_mode, profiles.first_name, profiles.last_name from users, profiles where users.id in (1220, 1233) and profiles.user_id = users.id;
update users set status = 'Installed' where id in (1220, 1233);
update users set demo_mode = fa where id in (1220, 1233);

/* Ordered by state for jill */
      SELECT distinct (users.id) as user_id, profiles.first_name, profiles.last_name, profiles.city, profiles.state, profiles.zipcode, profiles.home_phone, profiles.cell_phone, groups.name, users.status, users.test_mode, users.demo_mode, users.vip, users.created_at
        from users LEFT OUTER JOIN profiles ON users.id = profiles.user_id, roles, roles_users, groups 
        where users.id = roles_users.user_id 
        and roles_users.role_id = roles.id 
        and roles.name = 'halouser'
        and roles.authorizable_type = 'Group' 
        and roles.authorizable_id = groups.id
        and groups.name != 'safety_care'
        and status = 'Installed' and demo_mode != true
        order by users.id;
        order by profiles.state asc, users.created_at desc;      