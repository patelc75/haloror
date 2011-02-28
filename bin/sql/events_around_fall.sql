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

----- debugging statements -------------------------------------------------------------------------------
select * from falls where user_id = 1;
select * from events where event_type in ('BatteryPlugged', 'BatteryUnplugged') and user_id = 1 order by timestamp asc;
select * from battery_pluggeds where user_id = 1;
select * from battery_pluggeds order by id desc limit 100;
select count(*) from battery_pluggeds;