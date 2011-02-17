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
select * from events where event_type in ('BatteryPlugged', 'BatteryUnplugged') and user_id = 1 and timestamp > '2011-01-24 00:06:00+00' and timestamp <'2011-01-31 00:06:00+00' order by timestamp asc;
select * from battery_charge_periods_function(, '2009-10-10', now());
select sum(duration) from battery_charge_periods;
delete from battery_charge_periods;
select * from usage_minus_lost_data_gaps_and_battery_charge(261, '2011-02-08', now(), '90 seconds');
select * from usage_minus_lost_data_gaps_and_battery_charge_multiple(array_agg(select id from users limit 2), '2011-02-08', now(), '90 seconds');
select array_agg(any (select id from users limit 2));
--http://stackoverflow.com/questions/3848679/sql-error-more-than-one-row-returned-by-a-subquery-used-as-an-expression

select date_trunc('second', usage_minus_lost_data_gaps_and_battery_charge) from usage_minus_lost_data_gaps_and_battery_charge(261, '2011-02-08', now(), '90 seconds');
select extract(usage_minus_lost_data_gaps_and_battery_charge from usage_minus_lost_data_gaps_and_battery_charge(261, '2011-02-08', now(), '90 seconds'));
select extract(epoch from '2007-09-22 17:00'::timestamp);
select to_char('6 days 19:18:21'::interval, 'HH24'+'D'*24);
select extract('epoch' from '6 days 19:18:21'::interval) / 3600;  

/* instructions for brandon ------------------------------------------------------------------- */
select * from usage_minus_lost_data_gaps_and_battery_charge(1, '2011-02-08', now(), '90 seconds');
select * from battery_charge_periods where user_id = 1;
select *,end_time-begin_time as duration from lost_datas where user_id = 1;

/* General queries for debuging --------------------------------------------------------------------------------------- */
select *,end_time-begin_time as duration from lost_datas where user_id = 78 
select * from battery_charge_periods_function(1, '2009-01-01', now());
select usage from usage(1, '2009-10-10', now(), '90 seconds');
CREATE TABLE battery_charge_periods(id serial primary key, user_id integer, begin_time timestamp with time zone, end_time timestamp with time zone, duration interval);

/* usage_minus_lost_data_gaps_and_battery_charge for an array of users instead of a single user -------------------------------------------------------------------------------------- */
      DROP FUNCTION usage_minus_lost_data_gaps_and_battery_charge_multiple(user_ids integer[], p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
      CREATE OR REPLACE FUNCTION usage_minus_lost_data_gaps_and_battery_charge_multiple(user_ids integer[], p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
       RETURNS void AS
       $$
     	 declare
     	 begin
	  FOR i in array_lower(user_ids, 1) .. array_upper(user_ids, 1) LOOP
	     Raise Notice '%', user_ids[i]::integer;
	     select * from usage_minus_lost_data_gaps_and_battery_charge(user_ids[i]::integer, '2011-02-08', now(), '90 seconds');
	  END LOOP;
     	 end;
       $$ language plpgsql; 


/* use this to return a table -------------------------------------------------------------------------------------- */
       create or replace function GetNum(int) returns setof numtype as
	declare
	r numtype%rowtype;
	i int;
	begin
	for i in 1 .. $1 loop
	r.num := i;
	r.doublenum := i*2;
	return next r;
	end loop;
	return;
	end
      language 'plpgsql';


/* Create a query for a strap fasten/removed within X minutes post fall ------------------------------------------------------- */
CREATE OR REPLACE FUNCTION usage_minus_lost_data_gaps_and_battery_charge_multiple(user_ids integer[], p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
RETURNS void AS
$$
declare
 sf_post
 sf_pre
 sr_post
 sr_pre
begin
end;
$$ language plpgsql; 


/* Create a query for batteryplugged/batteryunplugged within X minutes post fall ------------------------------------------------------- */
CREATE OR REPLACE FUNCTION usage_minus_lost_data_gaps_and_battery_charge_multiple(user_ids integer[], p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
RETURNS void AS
$$
declare
 bp_post
 bp_pre
 bp_post
 bp_pre
begin
bp_post = 


explain select bp.timestamp from battery_pluggeds bp where ('2009-11-05 20:08:36+00'::timestamp + interval '10 minutes') > bp.timestamp  and '2009-11-05 20:08:36+00' < bp.timestamp and bp.user_id=1

select * from falls where user_id = 1 and timestamp > '2009-11-01';
select * from strap_fasteneds where user_id = 1;
select * from battery_pluggeds;
select * from battery_unpluggeds where user_id = 1;


SELECT user_id, timestamp, event_type,
	CASE 
	 WHEN (SELECT timestamp FROM gw_alarm_buttons gwab where gwab.timestamp > e.timestamp order by gwab.timestamp desc limit 1) is not null
	 THEN now()
	END
from events e
WHERE event_type in ('Fall', 'Panic');