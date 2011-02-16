/* run  the lost_data_skin_temps query ------------------------------------------------------------------------------- */
select * from lost_data_skin_temp_function(78, '2000-9-04 17:15:44+00', now(), '6 seconds');
select *,end_time-begin_time as duration from lost_data_skin_temps where user_id = 78;
select * from skin_temps;

/* run  the lost_data (vitals) query --------------------------------------------------------------------------------- */
select * from vitals where user_id = 1 order by timestamp asc limit 1000;
select * from lost_data_function(1, '2011-01-28', now(), '1 second');
select *,end_time-begin_time as duration from lost_datas where user_id = 1;
select sum(end_time-begin_time) from lost_datas where user_id = 1;
delete from lost_datas;

/* refs #4183 queries for calculate battery periods ------------------------------------------------------------------- */
DROP TABLE battery_charge_periods;
select * from events where event_type in ('BatteryPlugged', 'BatteryUnplugged') and user_id = 1 order by timestamp asc;
select * from battery_charge_periods_function(1, '2009-10-10', now());
select * from battery_charge_periods;
select sum(duration) from battery_charge_periods;
delete from battery_charge_periods;

/* General queries for debuging --------------------------------------------------------------------------------------- */
select *,end_time-begin_time as duration from lost_datas where user_id = 78 
select * from battery_charge_periods_function(1, '2009-01-01', now());
select usage from usage(1, '2009-10-10', now(), '90 seconds');

CREATE TABLE battery_charge_periods(id serial primary key, user_id integer, begin_time timestamp with time zone, end_time timestamp with time zone, duration interval);

	

  