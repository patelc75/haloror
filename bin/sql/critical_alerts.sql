
/* email report from server */
mutt -s "panic/fall delays" -a panic_delays.txt -a fall_delays.txt chirag@halomonitoring.com < email.txt 

/* show users info */
select users.id, users.login, profiles.first_name, profiles.last_name from users, profiles where users.id in (229, 230,231,232, 233) and profiles.user_id = users.id;

/* installed users (sql from wiki) 194 falls + 81 panics for Dec 2010 */
select user_id, timestamp, timestamp_call_center, call_center_pending as pend from falls 
where timestamp_call_center > '2010-12-01' and timestamp_call_center < '2011-01-01'
and user_id in 
(select user_id
from users_by_role('halouser') 
where status = 'Installed' 
order by vip desc, created_at desc);

/* installed users (sql from wiki) 197 falls + 97 panics = 284 total alerts for Dec 2010 */
select user_id, timestamp, timestamp_call_center, call_center_pending as pend from panics 
where timestamp_call_center > '2010-12-01' and timestamp_call_center < '2011-01-01';

select falls.user_id, falls.timestamp, falls.timestamp_call_center, falls.timestamp_server, falls.call_center_pending as pend, devices.serial_number 
from falls, devices_users, devices
where falls.user_id = devices_users.user_id 
and devices.id = devices_users.device_id 
and timestamp_call_center > '2010-12-01' and timestamp_call_center < '2011-01-01'
and devices.serial_number not like '%H2%' 
order by devices.serial_number desc
limit 1000;


select falls.user_id, falls.timestamp,falls.timestamp_server, falls.timestamp_call_center, falls.call_center_pending as pend, devices.serial_number 
from falls, devices_users, devices
where falls.user_id = devices_users.user_id 
and devices.id = devices_users.device_id 
and devices.serial_number not like '%H2%' 
and falls.user_id = 1263
order by devices.serial_number desc
limit 1000;

select panics.user_id, panics.timestamp, panics.timestamp_server, panics.timestamp_call_center, panics.call_center_pending as pend, devices.serial_number 
from panics, devices_users, devices
where panics.user_id = devices_users.user_id 
and devices.id = devices_users.device_id 
and devices.serial_number not like '%H2%' 
and panics.user_id = 1263
order by devices.serial_number desc
limit 1000;

/* critical alerts with more than 5 min delay from GW to server */
select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server as delay 
from falls 
where timestamp_call_center-timestamp_server > interval'5 minutes' 
order by id desc limit 100;

/* users with critical alerts with more than 5 min delay from GW to server within last month */
select distinct panics.user_id, profiles.first_name, profiles.last_name, profiles.city, profiles.state 
from panics, profiles  
where ((timestamp_server-timestamp) > interval'5 minutes') 
and timestamp_call_center is not null
and timestamp > now() - interval '1 week'
and panics.user_id = profiles.user_id
order by user_id desc;

/*Critical Alerts of more than 5 minutes */
select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server  as delay from falls where timestamp_call_center-timestamp_server > interval'5 minutes' order by id desc limit 100;

select id, timestamp, timestamp_call_center, timestamp_server, timestamp_call_center-timestamp_server  as delay from panics where ((timestamp_call_center-timestamp_server) > interval'5 minutes') order by id desc limit 100;

/*Try to get subsequent gw_alarm_button after a fall or panic */
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


select id, user_id, timestamp, timestamp_server, timestamp_call_center, call_center_pending as pend from falls order by id desc limit 20;