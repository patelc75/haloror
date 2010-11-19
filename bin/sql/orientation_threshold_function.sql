/*this file can be opened in PgAdmin to test orientation_threshold_function */ 
select * from lost_data_function( 78, null, now(), '10 seconds');
select * from lost_datas;
delete from lost_datas;
select * from orientation_threshold_function( 78, NULL, now(), '360 seconds', 115, 360);
select * from orientation_threshold_function( 78,'2010-11-18 19:15:45', now(), '360 seconds', 0, 111);
select *,end_time-begin_time as duration from orientation_thresholds;
delete from orientation_thresholds;

insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:15:45');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:20:45');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:21:00');
insert into vitals (user_id, orientation, timestamp) values (78, 114, '2010-11-18 20:22:00');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:23:00');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:28:00');
insert into vitals (user_id, orientation, timestamp) values (78, 114, '2010-11-18 20:32:00');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:38:00');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:39:00');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:40:00');
insert into vitals (user_id, orientation, timestamp) values (78, 110, '2010-11-18 20:44:01');

select * from vitals limit 10;
delete from vitals;
select * from vitals where user_id = 78;
delete from vitals where user_id = 78;


SELECT p.prosrc as "Source code"
FROM pg_catalog.pg_proc p
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
     LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang
WHERE p.proname ~ '^(orientation_threshold_function)$'
  AND pg_catalog.pg_function_is_visible(p.oid); 