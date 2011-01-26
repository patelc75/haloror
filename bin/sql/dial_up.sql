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

