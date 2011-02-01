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

/* Users with associated profiles */
select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (1288, 1303) and profiles.user_id = users.id;
select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (1295, 1296, 1297, 1298, 1299) and profiles.user_id = users.id order by users.id asc;
select users.id, profiles.first_name, profiles.last_name, users.activated_at, users.activation_code, users.status, users.demo_mode from users, profiles where profiles.user_id = users.id order by users.id desc;
select users.id, users.login, profiles.first_name, profiles.last_name, users.activated_at, users.status, users.demo_mode from users, profiles where users.id in (select user_id from user_intakes_users where user_intake_id = 33) and profiles.user_id = users.id order by users.id asc;

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

select * from mgmt_responses where id in (3712791, 3713124);
select user_id, software_version, mgmt_response_id from device_infos where software_version like '%1319%'; 
s
select di.user_id, di.device_id, di.software_version, mr.timestamp_server from device_infos di, mgmt_responses mr 
where di.mgmt_response_id = mr.id
and di.software_version not like '%2.01.01.421%'
and user_id in (248)
limit 1000;

SELECT user_id, timestamp, event_type,
	CASE 
	 WHEN (SELECT timestamp FROM gw_alarm_buttons gwab where gwab.timestamp > e.timestamp order by gwab.timestamp desc limit 1) is not null
	 THEN now()
	END
from events e
WHERE event_type in ('Fall', 'Panic');
		
SELECT au_lname, au_fname, title, Category =
        CASE
         WHEN (SELECT AVG(royaltyper) FROM titleauthor ta
                           WHERE t.title_id = ta.title_id) > 65
                 THEN 'Very High'
         WHEN (SELECT AVG(royaltyper) FROM titleauthor ta
                           WHERE t.title_id = ta.title_id)
                                     BETWEEN 55 and 64
                 THEN 'High'
         WHEN (SELECT AVG(royaltyper) FROM titleauthor ta
                           WHERE t.title_id = ta.title_id)
                                     BETWEEN 41 and 54
                 THEN 'Moderate'
         ELSE 'Low'
       END
FROM authors a,
     titles t,
     titleauthor ta
WHERE a.au_id = ta.au_id
AND   ta.title_id = t.title_id
ORDER BY Category, au_lname, au_fname


/*ADL pie chart on server WWW
UID #1
12am CST - 4am CST last night (morning of Jan 20) */
select * from vitals where user_id = 1 and timestamp > '2011-01-20 05:00' and timestamp < '2011-01-20 09:00' limit 1000;

curl -v -k -H "Content-Type: text/xml" -d "<fall><device_id>1</device_id><gw_timestamp>Mon Dec 25 15:52:55 -0600 2007</gw_timestamp><magnitude>60</magnitude><severity>12</severity><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><user_id>520</user_id></fall>" "https://ldev.myhalomonitor.com/falls?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 

select id, user_id, timestamp, timestamp_server from falls where timestamp_server is not null order by timestamp_server desc limit 100;

/*--------------------refs #4091 no HR for Critical Health ---------------------*/

select id from devices where serial_number like '%H200000226%';
select * from devices_users where device_id in (select id from devices where serial_number like '%H200000226%');
select * from vitals where user_id = 230 order by id desc limit 1000 ;

/*----------------------------------refs #4090 LDEV no 200OK issue and device_infos issue-----------------------------------------*/              
curl --insecure -v -i -H "Content-Type: text/xml" -d "<alert_bundle>
<timestamp>Tue Jan 25 21:52:20 UTC 2011</timestamp>
<fall>
<gw_timestamp>Tue Jan 25 21:52:18 UTC 2011</gw_timestamp>
<magnitude>0</magnitude>
<severity>3</severity>
<timestamp>Tue Jan 25 21:52:17 UTC 2011</timestamp>
<user_id>54</user_id>
</fall>
</alert_bundle>" "https://ldev.crit1.data.halomonitor.com/alert_bundle?gateway_id=148&auth=e0c4b1c680f503399b0afe552a043e692635a2d3a86700b98719e37e40c6846b"



curl --insecure -v -k -H "Content-Type: text/xml" -d "<alert_bundle>
<timestamp>Tue Jan 25 21:43:02 UTC 2011</timestamp>
<panic>
<duration_press>218</duration_press>
<gw_timestamp>Tue Jan 25 21:43:00 UTC 2011</gw_timestamp>
<timestamp>Tue Jan 25 21:42:59 UTC 2011</timestamp>
<user_id>54</user_id>
</panic>
</alert_bundle>" "http://ldev.crit1.data.halomonitor.com/alert_bundle?gateway_id=148&auth=796cb7db46b740c9bee727417c367caa1c680b2cc09db2c05eedf019d484ae83"

       -k/--insecure
              (SSL) This option explicitly allows curl to perform "insecure" SSL connections and transfers.  All  SSL  connections  are
              attempted  to  be made secure by using the CA certificate bundle installed by default. This makes all connections consid-
              ered "insecure" fail unless -k/--insecure is used.
       -i/--include
              (HTTP)  Include  the  HTTP-header  in the output. The HTTP-header includes things like server-name, date of the document,
              HTTP-version and more...

curl -v -H "Content-Type: text/xml" -d "<management_response_device><cmd_type>info</cmd_type><device_id>12</device_id><info><hardware_version>00.01</hardware_version><mac_address>00:00:11:00:00:08</mac_address><model>A</model><serial_num>H2D0000008</serial_num><software_version>00.00r35</software_version><user_id>8</user_id><vendor>Halo</vendor></info><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp></management_response_device>" "http://localhost:3000/mgmt_responses?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 


curl -v -H "Content-Type: text/xml" -d "<management_query_device><cycle_num>1</cycle_num><device_id>9</device_id><timestamp>Mon Dec 25 15:52:55 -0600 2007</timestamp><poll_rate>60</poll_rate></management_query_device>" "http://localhost:3000/mgmt_queries?gateway_id=0&auth=9ad3cad0f0e130653ec377a47289eaf7f22f83edb81e406c7bd7919ea725e024" 

