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

select * from alert_options;
select * from alert_types;

select * from caregivers_by_user_id(5);

select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server  as delay from falls where timestamp_call_center-timestamp_server > interval'5 minutes' order by id desc limit 100;

select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server  as delay from panics where ((timestamp_call_center-timestamp_server) > interval'5 minutes') order by id desc limit 100;

select users.id, users.login, profiles.first_name, profiles.last_name from users, profiles where users.id in (229, 230,231,232, 233) and profiles.user_id = users.id;


curl -v -k -H "Content-Type: text/xml" -d "<dial_up_status><device_id>5773</device_id><alt_number>2567053101</alt_number><alt_status>success</alt_status><alt_username>halo</alt_username><alt_password>gepitka</alt_password><alt_configured>new</alt_configured><alt_num_failures>0</alt_num_failures><alt_consecutive_fails>0</alt_consecutive_fails><alt_ever_connected>False</alt_ever_connected><number>2562700020</number><status>success</status><username>halopoolplan@earthlink.net</username><password>UKA8aKh5</password><configured>new</configured><num_failures>0</num_failures><consecutive_fails>0</consecutive_fails><ever_connected>True</ever_connected><global_alt_number>18772383816</global_alt_number><global_alt_status>success</global_alt_status><global_alt_username>halo</global_alt_username><global_alt_password>gepitka</global_alt_password><global_alt_configured>new</global_alt_configured><global_alt_num_failures>0</global_alt_num_failures><global_alt_consecutive_fails>0</global_alt_consecutive_fails><global_alt_ever_connected>False</global_alt_ever_connected><global_prim_number>18008537921</global_prim_number><global_prim_status>success</global_prim_status><global_prim_username>halopoolplan@earthlink.net</global_prim_username><global_prim_password>UKA8aKh5</global_prim_password><global_prim_configured>new</global_prim_configured><global_prim_num_failures>0</global_prim_num_failures><global_prim_consecutive_fails>0</global_prim_consecutive_fails><global_prim_ever_connected>False</global_prim_ever_connected><last_successful_number>2562700020</last_successful_number><last_successful_username>halopoolplan@earthlink.net</last_successful_username><last_successful_password>UKA8aKh5</last_successful_password><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><lowest_connect_rate>100</lowest_connect_rate><lowest_connect_timestamp>Mon Dec 25 15:52:55 -0600 2011</lowest_connect_timestamp></dial_up_status>" "https://sdev.myhalomonitor.com/dial_up_statuses?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 

select * from dial_up_statuses order by id desc;
select * from dial_up_last_successfuls order by id desc;

<dial_up_status><device_id>5773</device_id><alt_number>2567053101</alt_number><alt_status>success</alt_status><alt_username>halo</alt_username><alt_password>gepitka</alt_password><alt_configured>new</alt_configured><alt_num_failures>0</alt_num_failures><alt_consecutive_fails>0</alt_consecutive_fails><alt_ever_connected>False</alt_ever_connected><number>2562700020</number><status>success</status><username>halopoolplan@earthlink.net</username><password>UKA8aKh5</password><configured>new</configured><num_failures>0</num_failures><consecutive_fails>0</consecutive_fails><ever_connected>True</ever_connected><global_alt_number>18772383816</global_alt_number><global_alt_status>success</global_alt_status><global_alt_username>halo</global_alt_username><global_alt_password>gepitka</global_alt_password><global_alt_configured>new</global_alt_configured><global_alt_num_failures>0</global_alt_num_failures><global_alt_consecutive_fails>0</global_alt_consecutive_fails><global_alt_ever_connected>False</global_alt_ever_connected><global_prim_number>18008537921</global_prim_number><global_prim_status>success</global_prim_status><global_prim_username>halopoolplan@earthlink.net</global_prim_username><global_prim_password>UKA8aKh5</global_prim_password><global_prim_configured>new</global_prim_configured><global_prim_num_failures>0</global_prim_num_failures><global_prim_consecutive_fails>0</global_prim_consecutive_fails><global_prim_ever_connected>False</global_prim_ever_connected><last_successful_number>2562700020</last_successful_number><last_successful_username>halopoolplan@earthlink.net</last_successful_username><last_successful_password>UKA8aKh5</last_successful_password><timestamp>Thu Jan 06 14:59:22 UTC 2011</timestamp></dial_up_status><lowest_connect_rate>31200</lowest_connect_rate><longest_dial_duration_sec>213</longest_dial_duration_sec>

select id, user_id, timestamp, weight, weight_unit, battery, serial_number from weight_scales where user_id != 0 order by id desc;


