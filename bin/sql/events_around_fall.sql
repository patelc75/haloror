----- strap fastened and strap removed X minutes before (pre) and after (post) a fall for a given user--------
explain select f.id, f.timestamp, 
 (select sf.timestamp from strap_fasteneds sf where (sf.user_id=f.user_id and f.timestamp + interval '10 minutes' > sf.timestamp and sf.timestamp > f.timestamp) order by sf.timestamp asc  limit 1) as sf_post,
 (select sf.timestamp from strap_fasteneds sf where (sf.user_id=f.user_id and f.timestamp - interval '10 minutes' < sf.timestamp and sf.timestamp < f.timestamp) order by sf.timestamp desc limit 1) as sf_pre,	  
 (select sr.timestamp from strap_removeds  sr where (sr.user_id=f.user_id and f.timestamp + interval '10 minutes' > sr.timestamp and sr.timestamp > f.timestamp) order by sr.timestamp asc  limit 1) as sr_post,  
 (select sr.timestamp from strap_removeds  sr where (sr.user_id=f.user_id and f.timestamp - interval '10 minutes' < sr.timestamp and sr.timestamp < f.timestamp) order by sr.timestamp desc limit 1) as sr_pre
from falls f
where f.user_id = 1
and timestamp > now() - interval '1 week'
and timestamp < now();

----- battery plugged and battery unplugged X minutes before (pre) and after (post) a fall for a given user--------
select f.id, f.timestamp, 
 (select bp.timestamp from battery_pluggeds   bp where (bp.user_id=f.user_id and f.timestamp + interval '10 minutes' > bp.timestamp and bp.timestamp > f.timestamp) order by bp.timestamp asc  limit 1) as bp_post,
 (select bp.timestamp from battery_pluggeds   bp where (bp.user_id=f.user_id and f.timestamp - interval '10 minutes' < bp.timestamp and bp.timestamp < f.timestamp) order by bp.timestamp desc limit 1) as bp_pre,
 (select bu.timestamp from battery_unpluggeds bu where (bu.user_id=f.user_id and f.timestamp + interval '10 minutes' > bu.timestamp and bu.timestamp > f.timestamp) order by bu.timestamp asc  limit 1) as bu_post,  
 (select bu.timestamp from battery_unpluggeds bu where (bu.user_id=f.user_id and f.timestamp - interval '10 minutes' < bu.timestamp and bu.timestamp < f.timestamp) order by bu.timestamp desc limit 1) as bu_pre
from falls f
where f.user_id = 1
and timestamp > now() - interval '1 week'
and timestamp < now();

----- debugging statements -------------------------------------------------------------------------------
select * from falls where user_id = 1;
select * from events where event_type in ('BatteryPlugged', 'BatteryUnplugged') and user_id = 1 order by timestamp asc;
select * from battery_pluggeds where user_id = 1;