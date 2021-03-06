--------- Queries in this section here are used by engineering and tech support ---------
select dial_up_alerts.id, users.id as user_id, dial_up_alerts.device_id, phone_number, username, password, alt_number, alt_username, alt_password, last_successful_number, timestamp as las_suc_num 
from dial_up_alerts, users, devices_users 
where users.id = devices_users.user_id 
and dial_up_alerts.device_id = devices_users.device_id 
and timestamp > now() - interval '1 week'
order by user_id asc, timestamp desc limit 1000;


--------- Queries in this section here are used by health server development ------------
select id, device_id as did, phone_number as phone_num, status, configured as conf, num_failures as num_f, consecutive_fails as consec_f, ever_connected as ever, dialup_type as type, created_at 
from dial_up_statuses 
where status = 'fail' 
and created_at is not null 
order by created_at desc  limit 1000;


select id, device_id as did, phone_number as phone_num, status, configured as conf, num_failures as num_f, consecutive_fails as consec_f, ever_connected as ever, dialup_type as type, dialup_rank as rank, created_at 
from dial_up_statuses 
where device_id in (368)
and created_at is not null 
order by created_at desc limit 1000;

select * from dial_up_statuses where status = 'fail' and created_at is not null and id in (30784, 30785, 30786) order by created_at desc;

select id, device_id as did, phone_number as phone_num, status, configured as conf, num_failures as num_f, consecutive_fails as consec_f, ever_connected as ever, dialup_type as type, created_at from dial_up_statuses where status = 'fail' and created_at is not null order by created_at desc;
select * from dial_up_statuses where status = 'fail' and created_at is not null order by created_at desc;

-[ RECORD 1 ]-------------------+---------------------------
id                              | 30786
device_id                       | 5981
phone_number                    | 18008537921
status                          | fail
configured                      | new
num_failures                    | 2
consecutive_fails               | 2
ever_connected                  | f
dialup_type                     | Global
created_at                      | 2010-12-12 16:11:47.437541
updated_at                      | 2010-12-12 16:11:47.437541
lowest_connect_rate             | 0
lowest_connect_timestamp        | 
longest_dial_duration_sec       | 0
longest_dial_duration_timestamp | 
username                        | 
password                        | 
alt_username                    | 
alt_password                    | 
global_alt_username             | 
global_alt_password             | 
global_prim_username            | 
global_prim_password            | 
-[ RECORD 2 ]-------------------+---------------------------


select id, device_id, username, password, alt_username, alt_password, last_successful_number  as las_suc_num, timestamp from dial_up_alerts order by timestamp desc;

/*refs #4115 check on user intake dial up numbers column */
 select device_id, timestamp_initiated, originator as orig, pending as pend, created_by as cb from mgmt_cmds where cmd_type LIKE '%dial_up_num_glob%' limit 100;

select mgmt_cmds.device_id, users.id as user_id, profiles.first_name, profiles.last_name, mgmt_cmds.cmd_type, mgmt_cmds.timestamp_initiated, mgmt_cmds.originator as orig, mgmt_cmds.pending as pend, mgmt_cmds.created_by as cb
from profiles left outer join users on users.id = profiles.user_id, mgmt_cmds, devices_users 
where mgmt_cmds.device_id = devices_users.device_id 
and devices_users.user_id = users.id
and mgmt_cmds.cmd_type LIKE '%dial_up%' 
and users.id in (1284, 1258, 1277, 1243, 1295, 1267, 1289, 1294, 1288, 1263, 1251, 1275, 1256, 1252, 1237, 1226, 1227, 1218)
order by mgmt_cmds.id desc limit 100;



select * from mgmt_cmds where cmd_type  not like '%user%' and cmd_type not like '%info%' and cmd_type not like '%reset$' and cmd_type not like '%reset%' and cmd_type not like '%firmware_upgrade%' order by id desc limit 1250;

select * from mgmt_cmds where cmd_type like '%dial_up%' and device_id = 178 order by id desc limit 1250;

select device_id, cmd_type, timestamp_initiated, originator as orig, pending as pend, created_by as cr from mgmt_cmds where cmd_type LIKE '%dial_up_num%' order by id desc limit 100;

select id from user_intakes;

select * from mgmt_cmds where device_id = 178 and cmd_type  not like '%user%'order by id desc limit 1250;

select device_id, cmd_type, timestamp_initiated, originator as orig, pending as pend from mgmt_cmds where device_id in (178) order by timestamp_initiated desc limit 100;