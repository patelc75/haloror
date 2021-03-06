-- kill Pg query --------------------------------
SELECT 
    pg_terminate_backend(19021) 
FROM 
    pg_stat_activity 
WHERE -- don't kill my own connection!
    procpid <> pg_backend_pid();
                                    
UtilityHelper.change_password_by_user_id(1599, 'bestswimer')

-- look for sucscribers for a given user
select * from users_by_user_intake_id(select user_intake_id from user_intakes_users where user_id = 901 limit 1);
select user_intake_id from user_intakes_users where user_id = 1477 limit 1;
select * from users_by_user_intake_id(89);
                                               
-- change group for user intake when broken!
select * from groups where name like 'ml_rickmontgomery';      -- get group_id 
select * from roles where authorizable_id = 239;               -- get role_id
select * from users_by_user_intake_id(203);                    -- get user_id, don't need this if user_id known
select * from user_intakes where id = 203;		                 -- check what the group_id is
insert into roles_users (user_id, role_id) values (1754, 782); -- update group                                          
update user_intakes set group_id = 127 where id = 203;         -- update group
	
-- refs #3666 debugging safetycare account number ------------------------------------------------------------------------------------------------
select id, first_name, last_name, account_number from profiles where account_number is not null order by account_number desc;
select id, first_name, last_name, account_number from profiles where account_number = '1125' order by account_number desc;
update profiles set account_number = '1111' where id in (459, 405, 1085, 711, 1108, 34, 1094, 999, 552, 967, 980, 47, 158);
update profiles set account_number = NULL where id in (459, 405, 1085, 711, 1108, 34, 1094, 999, 552, 967, 980, 47, 158);
select id, first_name, last_name, account_number from profiles where id in (11, 459, 405, 1085, 711, 1108, 34, 1094, 999, 552, 967, 980, 47, 158);

-- Users with associated profiles ----------------------------------------------------------------------------------------------------------------
select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (1288, 1303) and profiles.user_id = users.id;
select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (1295, 1296, 1297, 1298, 1299) and profiles.user_id = users.id order by users.id asc;
select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.activation_code, users.status, users.demo_mode from users, profiles where profiles.user_id = users.id order by users.id desc;
select users.id, users.login, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (select user_id from user_intakes_users where user_intake_id = 33) and profiles.user_id = users.id order by users.id asc;

-- device_infos debugging ------------------------------------------------------------------------------------------------------------
select * from mgmt_responses where id in (3712791, 3713124);
select user_id, software_version, mgmt_response_id from device_infos where software_version like '%1319%'; 

-- get the timestamp from the mgmt response when the device was upgraded (I think)
select di.user_id, di.device_id, di.software_version, mr.timestamp_server from device_infos di, mgmt_responses mr 
where di.mgmt_response_id = mr.id
and di.software_version not like '%2.01.01.421%'
and user_id in (248)
limit 1000;

/*ADL pie chart on server WWW UID #1 12am CST - 4am CST last night (morning of Jan 20) ------------------------------------------------*/
select * from vitals where user_id = 1 and timestamp > '2011-01-20 05:00' and timestamp < '2011-01-20 09:00' limit 1000;

select id, user_id, timestamp, timestamp_server from falls where timestamp_server is not null order by timestamp_server desc limit 100;

/*refs #4091 no HR for Critical Health ------------------------------------------------------------------------------------------------*/
select id from devices where serial_number like '%H200000226%';
select;* from devices_users where device_id in (select id from devices where serial_number like '%H200000226%');
select * from vitals where user_id = 230 order by id desc limit 1000;

/* Ready to bill users ----------------------------------------------------------------------------------------------------------------*/
select id, panic_received_at from user_intakes where id in (36, 31, 23, 28);
 id |     panic_received_at      
----+----------------------------
 23 | 2011-01-27 18:21:38.224152
 28 | 2011-01-22 21:51:38.483743
 36 | 2011-01-28 21:28:18.371577
 31 | 2011-01-30 14:50:18.278312

select id, user_id, timestamp_server from panics where user_id in (1277,1295,1243,1263) order by id desc limit 100;
  id  | user_id |       timestamp_server        
------+---------+-------------------------------
 6339 |    1277 | 2011-01-30 14:48:06.846377+00
 6327 |    1295 | 2011-01-28 21:26:08.259933+00
 6315 |    1243 | 2011-01-27 18:19:35.610368+00
 6283 |    1263 | 2011-01-22 21:49:33.059117+00

/* users_by_user_intake_id -------------------------------------------------------------------------------------------------------------*/
SELECT p.prosrc as "Source code"
FROM pg_catalog.pg_proc p
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
WHERE p.proname ~ '^(users_by_user_intake_id)$'
  AND pg_catalog.pg_function_is_visible(p.oid);

/* users_by_user_intake_id -------------------------------------------------------------------------------------------------------------*/
    select distinct roles_users.user_id, profiles.first_name, profiles.last_name, roles.name, roles_users_options.position as pos, roles_users_options.active as active, roles.authorizable_type as a_type, roles.authorizable_id as a_id, users.activated_at, users.login 
      from roles_users left outer join roles_users_options on roles_users.id = roles_users_options.roles_user_id, roles, users, profiles  
      where roles_users.user_id in (select users.id from users, profiles where users.id in (select user_id from user_intakes_users where user_intake_id = 32) and profiles.user_id = users.id) 
      and roles_users.user_id = users.id 
      and users.id = profiles.user_id
      and roles_users.role_id = roles.id
      order by roles_users_options.position asc, user_id;     


/* make sure user intake is updating user.installed_at---------------------------------------------------------------------------------------------------*/
select id, login, installed_at from users where id in (1263, 1284, 1277, 1243, 1309, 1317, 1310, 1295, 1288, 1306, 1294, 1267, 1258, 1289, 1251);

-- check test panics for all users---------------------------------------------------------------------------------------
select panics.id, panics.user_id, profiles.first_name, profiles.last_name, timestamp, test_mode from panics, profiles 
where test_mode = true
and panics.user_id = profiles.user_id
limit 100;

-- device_infos with a particular software verison------------------------------------------------------------------
select device_id, software_version, software_version_current as cur, software_version_new as new, created_at from device_infos where software_version like '%02.00.00.1334%' order by device_id desc, created_at desc;
                                                           
-- get the software version history ordered by upgraded at for a given user ----------------------------------------
select di.device_id, di.serial_number, di.user_id, u.login, p.first_name, p.last_name, di.software_version, di.software_version_current as cur, di.software_version_new as new, di.created_at as upgraded_at from device_infos di, users u, profiles p where di.user_id = u.id and di.user_id = p.user_id and device_id in (select device_id from devices_by_user_id(231)) order by di.created_at desc nulls last;     

select di.device_id, di.serial_number, di.user_id, u.login, di.software_version, di.created_at as upgraded_at from device_infos di, users u, profiles p where di.user_id = u.id and di.user_id = p.user_id and device_id in (select device_id from devices_by_user_id(231)) order by di.created_at desc nulls last;


select users.id as uid, devices.id as did, profiles.first_name, profiles.last_name, users.status 
from users, profiles, devices left outer join devices_users on devices_users.device_id = devices.id
where devices_users.user_id = users.id
and profiles.user_id = users.id
and devices.id in (select device_id from device_infos where device_id in (select device_id from device_infos where software_version like '%02.00.00.1334%') order by device_id desc, created_at desc nulls last)
order by devices.id desc
limit 1000;

select device_id, software_version, software_version_current as cur, software_version_new as new, created_at from device_infos where device_id < 2500 and created_at is not null order by device_id desc, created_at desc;

/* device unavailbles for last month for all users--------------------------------------------------------------------------------------------------*/
select dua.user_id, count(*) as count
from device_unavailable_alerts dua
where dua.created_at > now() - interval '30 days' 
group by dua.user_id 
order by count(*) desc
limit 1000;

select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (
select dua.user_id
from device_unavailable_alerts dua
where dua.created_at > now() - interval '30 days' 
group by dua.user_id 
order by count(*) desc
limit 1000) and profiles.user_id = users.id order by users.id asc;

---- refs #4224 CHT: Delays after GW reboot --------------------------
select * from vitals where user_id = 232 and timestamp > '2011-02-15' and timestamp < '2011-02-17' order by id desc limit 1000;

---- find all operators for alll groups --------------------------
select users.id, profiles.first_name, profiles.last_name, users.email, roles.authorizable_type as a_type, roles.authorizable_id as a_id
case when roles.authorizable_type = 'Group' 
then (select g.name from groups g where g.id = roles.authorizable_id) end as group_name
from roles, roles_users, profiles, users 
where roles.name = 'operator'
and roles_users.user_id = users.id
and profiles.user_id = users.id
and roles_users.role_id = roles.id
order by group_name;