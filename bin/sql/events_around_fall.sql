----- strap fastened and strap removed X minutes before (pre) and after (post) a fall for a given user--------
select f.id, f.timestamp, 
  case 
    when (select sf.timestamp from strap_fasteneds sf where (f.timestamp + interval '10 minutes' > sf.timestamp and sf.timestamp > f.timestamp and sf.user_id=f.user_id) order by sf.timestamp asc limit 1) is not null  
	then (select sf.timestamp from strap_fasteneds sf where (f.timestamp + interval '10 minutes' > sf.timestamp and sf.timestamp > f.timestamp and sf.user_id=f.user_id) order by sf.timestamp asc limit 1)
    else null 
  end as sf_post,
  case 
    when (select sf.timestamp from strap_fasteneds sf where (f.timestamp - interval '10 minutes' < sf.timestamp and sf.timestamp < f.timestamp and sf.user_id=f.user_id) order by sf.timestamp asc limit 1) is not null  
	then (select sf.timestamp from strap_fasteneds sf where (f.timestamp - interval '10 minutes' < sf.timestamp and sf.timestamp < f.timestamp and sf.user_id=f.user_id) order by sf.timestamp asc limit 1)
    else null 
  end as sf_pre,	  
  case 
    when (select sr.timestamp from strap_removeds sr where (f.timestamp + interval '10 minutes' > sr.timestamp and sr.timestamp > f.timestamp and sr.user_id=f.user_id) order by sr.timestamp asc limit 1) is not null  
	then (select sr.timestamp from strap_removeds sr where (f.timestamp + interval '10 minutes' > sr.timestamp and sr.timestamp > f.timestamp and sr.user_id=f.user_id) order by sr.timestamp asc limit 1)
    else null 
  end as sr_post,  
  case 
    when (select sr.timestamp from strap_removeds sr where (f.timestamp - interval '10 minutes' < sr.timestamp and sr.timestamp < f.timestamp and sr.user_id=f.user_id) order by sr.timestamp asc limit 1) is not null  
	then (select sr.timestamp from strap_removeds sr where (f.timestamp - interval '10 minutes' < sr.timestamp and sr.timestamp < f.timestamp and sr.user_id=f.user_id) order by sr.timestamp asc limit 1)
    else null 
  end as sr_pre	
from falls f
where f.user_id = 1
and timestamp > now() - interval '1 week'
and timestamp < now();

----- battery plugged and battery unplugged X minutes before (pre) and after (post) a fall for a given user--------
select f.id, f.timestamp, 
  case 
    when (select bp.timestamp from battery_pluggeds bp where (f.timestamp + interval '10 minutes' > bp.timestamp and bp.timestamp > f.timestamp and bp.user_id=f.user_id) order by bp.timestamp asc limit 1) is not null  
	then (select bp.timestamp from battery_pluggeds bp where (f.timestamp + interval '10 minutes' > bp.timestamp and bp.timestamp > f.timestamp and bp.user_id=f.user_id) order by bp.timestamp asc limit 1)
    else null 
  end as bp_post,
  case 
    when (select bp.timestamp from battery_pluggeds bp where (f.timestamp - interval '10 minutes' < bp.timestamp and bp.timestamp < f.timestamp and bp.user_id=f.user_id) order by bp.timestamp asc limit 1) is not null  
	then (select bp.timestamp from battery_pluggeds bp where (f.timestamp - interval '10 minutes' < bp.timestamp and bp.timestamp < f.timestamp and bp.user_id=f.user_id) order by bp.timestamp asc limit 1)
    else null 
  end as bp_pre,
  case 
    when (select bu.timestamp from battery_unpluggeds bu where (f.timestamp + interval '10 minutes' > bu.timestamp and bu.timestamp > f.timestamp and bu.user_id=f.user_id) order by bu.timestamp asc limit 1) is not null  
	then (select bu.timestamp from battery_unpluggeds bu where (f.timestamp + interval '10 minutes' > bu.timestamp and bu.timestamp > f.timestamp and bu.user_id=f.user_id) order by bu.timestamp asc limit 1)
    else null 
  end as bu_post,  
  case 
    when (select bu.timestamp from battery_unpluggeds bu where (f.timestamp - interval '10 minutes' < bu.timestamp and bu.timestamp < f.timestamp and bu.user_id=f.user_id) order by bu.timestamp asc limit 1) is not null  
	then (select bu.timestamp from battery_unpluggeds bu where (f.timestamp - interval '10 minutes' < bu.timestamp and bu.timestamp < f.timestamp and bu.user_id=f.user_id) order by bu.timestamp asc limit 1)
    else null 
  end as bu_pre	
from falls f
where f.user_id = 1
and timestamp > now() - interval '1 week'
and timestamp < now();