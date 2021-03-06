----- strap fastened and strap removed X minutes before (pre) and after (post) a fall for a given user--------
select f.id, f.timestamp, 
 (select sf.timestamp from strap_fasteneds sf where (sf.user_id=f.user_id and f.timestamp + interval '10 minutes' > sf.timestamp and sf.timestamp > f.timestamp) order by sf.timestamp asc  limit 1) as sf_post,
 (select sf.timestamp from strap_fasteneds sf where (sf.user_id=f.user_id and f.timestamp - interval '10 minutes' < sf.timestamp and sf.timestamp < f.timestamp) order by sf.timestamp desc limit 1) as sf_pre,	  
 (select sr.timestamp from strap_removeds  sr where (sr.user_id=f.user_id and f.timestamp + interval '10 minutes' > sr.timestamp and sr.timestamp > f.timestamp) order by sr.timestamp asc  limit 1) as sr_post,  
 (select sr.timestamp from strap_removeds  sr where (sr.user_id=f.user_id and f.timestamp - interval '10 minutes' < sr.timestamp and sr.timestamp < f.timestamp) order by sr.timestamp desc limit 1) as sr_pre
from falls f
where f.user_id in (230)
and timestamp > now() - interval '2 weeks'
and timestamp < now()
limit 1000;

----- battery plugged and battery unplugged X minutes before (pre) and after (post) a fall for a given user--------
select f.id, f.timestamp, 
 (select bp.timestamp from battery_pluggeds   bp where (bp.user_id=f.user_id and f.timestamp + interval '10 minutes' > bp.timestamp and bp.timestamp > f.timestamp) order by bp.timestamp asc  limit 1) as bp_post,
 (select bp.timestamp from battery_pluggeds   bp where (bp.user_id=f.user_id and f.timestamp - interval '10 minutes' < bp.timestamp and bp.timestamp < f.timestamp) order by bp.timestamp desc limit 1) as bp_pre,
 (select bu.timestamp from battery_unpluggeds bu where (bu.user_id=f.user_id and f.timestamp + interval '10 minutes' > bu.timestamp and bu.timestamp > f.timestamp) order by bu.timestamp asc  limit 1) as bu_post,  
 (select bu.timestamp from battery_unpluggeds bu where (bu.user_id=f.user_id and f.timestamp - interval '10 minutes' < bu.timestamp and bu.timestamp < f.timestamp) order by bu.timestamp desc limit 1) as bu_pre
from falls f
where f.user_id in (1)
and timestamp > now() - interval '1 week'
and timestamp < now()
limit 1000;

------ battery pluggeds while the strap is fastened ------------------------------------------------------
SELECT bp.id, bp.user_id as user_id, bp.timestamp, 
 CASE when
   (select sf.timestamp from strap_fasteneds sf where (sf.user_id=bp.user_id and sf.timestamp < bp.timestamp) order by sf.timestamp desc limit 1) >
   (select sr.timestamp from strap_removeds  sr where (sr.user_id=bp.user_id and sr.timestamp < bp.timestamp) order by sr.timestamp desc limit 1)
 THEN 
  'Strap Fastened'
 ELSE
  'Strap Removed'
 END as strap_state
from battery_pluggeds bp 
where bp.user_id in (1) 
and timestamp > now() - interval '2 weeks'
and timestamp < now()
order by strap_state asc
limit 1000;

------ falls while battery is charging for all users ------------------------------------------------------
SELECT f.id, f.user_id as user_id, f.timestamp, 
 CASE when
   (select bp.timestamp from battery_pluggeds   bp where (bp.user_id=f.user_id and bp.timestamp < f.timestamp) order by bp.timestamp desc limit 1) >
   (select bu.timestamp from battery_unpluggeds bu where (bu.user_id=f.user_id and bu.timestamp < f.timestamp) order by bu.timestamp desc limit 1)
 THEN 
  'Battery Plugged'
 ELSE
  'Battery Unplugged'
 END as battery_state
from falls f 
where f.user_id in (1)
and timestamp > now() - interval '2 weeks'
and timestamp < now()
order by battery_state asc
limit 1000;

----- falls, software version X minutes before (pre) and after (post), strap status, sensitivity, strap removed within x minutes, halo_debug_msgs ------------------
select hdm.id, hdm.user_id, hdm.timestamp, hdm.dbg_type, hdm.param3, 
 (select f.timestamp from falls f where (hdm.user_id=f.user_id and hdm.timestamp = f.timestamp) order by f.timestamp desc limit 1) as falls,
(select di.software_version from device_infos di
where hdm.user_id = di.user_id
and (di.serial_number like '%H1%' or di.serial_number like '%H5%')
and hdm.timestamp > di.created_at
order by di.created_at desc limit 1) as software_version,
CASE when
   (select sf.timestamp from strap_fasteneds sf where (sf.user_id=hdm.user_id and sf.timestamp < hdm.timestamp) order by sf.timestamp desc limit 1) >
   (select sr.timestamp from strap_removeds  sr where (sr.user_id=hdm.user_id and sr.timestamp < hdm.timestamp) order by sr.timestamp desc limit 1)
 THEN 
  'Strap Fastened'
 ELSE
  'Strap Removed'
 END as strap_state,
(select sr.timestamp from strap_removeds sr where (sr.user_id=hdm.user_id and hdm.timestamp + interval '2 minutes' > sr.timestamp and sr.timestamp > hdm.timestamp) order by sr.timestamp asc  limit 1) as sr_post
from halo_debug_msgs hdm
where (dbg_type = 4)
and hdm.timestamp > now() - interval '7 days'
and hdm.timestamp < now()
and user_id != 1
and user_id != 485
and user_id != 1250
order by software_version asc, user_id asc, timestamp desc limit 1000;

----- gw_alarm_buttons X minutes before (pre) and after (post) a fall for a given user-------------------
select f.id, f.user_id as user_id,'Fall' as crit_type, f.timestamp, 
 (select gab.timestamp from gw_alarm_buttons gab where (gab.user_id=f.user_id and f.timestamp + interval '10 minutes' > gab.timestamp and gab.timestamp > f.timestamp) order by gab.timestamp desc limit 1) as gw_alarm_button_post
from falls f
where timestamp > now() - interval '2 weeks'
and timestamp < now()
union all
select p.id, p.user_id as user_id, 'Panic' as crit_type, p.timestamp, 
 (select gab.timestamp from gw_alarm_buttons gab where (gab.user_id=p.user_id and p.timestamp - interval '10 minutes' < gab.timestamp and gab.timestamp < p.timestamp) order by gab.timestamp desc limit 1) as gw_alarm_button_post
from panics p
where timestamp > now() - interval '2 weeks'
and timestamp < now();
and p.user_id in (1)
limit 1000;

--------------------- Steps for 10 minutes post fall plus S/W version------------------------------
select f.id, f.user_id, f.timestamp,
(select di.software_version from device_infos di
where f.user_id = di.user_id
and (di.serial_number like '%H1%' or di.serial_number like '%H5%')
and f.timestamp > di.created_at
order by di.created_at desc limit 1) as software_version,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '1 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc  limit 1) as Step_1,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '2 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_2,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '3 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_3,  
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '4 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_4,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '5 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc  limit 1) as Step_5,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '6 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_6,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '7 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_7,  
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '8 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_8,
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '9 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_9,  
 (select steps.steps from steps  where (steps.user_id=f.user_id and f.timestamp + interval '10 minutes' > steps.begin_timestamp and steps.begin_timestamp > f.timestamp) order by steps.begin_timestamp desc limit 1) as Step_10
from falls f
where f.user_id in ()
and timestamp > now() - interval '2 weeks'
and timestamp < now()
order by user_id asc, timestamp desc limit 1000;

----- debugging statements -------------------------------------------------------------------------------
select * from falls where user_id = 1;
select * from events where event_type in ('BatteryPlugged', 'BatteryUnplugged') and user_id = 1 order by timestamp asc;
select * from battery_pluggeds where user_id = 1;
select * from battery_pluggeds order by id desc limit 100;
select count(*) from battery_pluggeds;