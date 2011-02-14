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

/* 20110214191001_user_compliance_function.rb starts here ------------------------------------------------------------- */

CREATE TABLE battery_charge_periods(id serial primary key, user_id integer, begin_time timestamp with time zone, end_time timestamp with time zone, duration interval);

CREATE OR REPLACE FUNCTION user_compliance(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
  RETURNS interval AS
$BODY$
        declare
          row record;
	  battery_charge_duration interval;
	  lost_data_duration interval;
	  total_duration interval;
        begin
          delete from battery_charge_periods where user_id = p_user_id;
          delete from lost_datas where user_id = p_user_id;

	  select * into row from battery_charge_periods_function(p_user_id, p_begin_time, p_end_time);
	  select * into row from lost_data_function(p_user_id, p_begin_time, p_end_time, p_lost_data_gap);
	  
	  select sum(duration) into battery_charge_duration from battery_charge_periods where user_id = p_user_id;
	  select sum(end_time-begin_time) into lost_data_duration from lost_datas where user_id = p_user_id;
	  RAISE NOTICE 'battery_charge_duration %', battery_charge_duration;
	  RAISE NOTICE 'lost_data_duration %', lost_data_duration;
	  if battery_charge_duration is NULL then
	    battery_charge_duration = interval '0 seconds';
	  end if;

	  if lost_data_duration is NULL then
	    lost_data_duration = interval '0 seconds';
	  end if;

	  total_duration = battery_charge_duration + lost_data_duration;
	  RAISE NOTICE 'total_duration %', total_duration;
	  return total_duration;
        end;
        $BODY$
LANGUAGE plpgsql VOLATILE
	
/* refs #4183 function calculate battery periods ------------------------------------------------------------------- */
/* Events without matching BatteryPlugged or BatteryPlugged are ignored. For example:
   BatteryPlugged > BatteryPlugged   > BatteryUnplugged
   BatteryPlugged > BatteryUnplugged > BatteryUnplugged */
CREATE OR REPLACE FUNCTION battery_charge_periods_function(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone)
  RETURNS void AS
$BODY$
        declare
          row record;
          prev_timestamp timestamp with time zone;
        begin
	  for row in (select timestamp, event_type from events where user_id = p_user_id AND timestamp <= p_end_time AND timestamp >= p_begin_time and event_type in ('BatteryPlugged', 'BatteryUnplugged') order by timestamp asc) loop
            if(row.event_type = 'BatteryPlugged') then
              prev_timestamp := row.timestamp;
            else
              if (prev_timestamp is not NULL) then
                insert into battery_charge_periods (user_id, begin_time, end_time, duration) values (p_user_id, prev_timestamp, row.timestamp, row.timestamp-prev_timestamp);
                prev_timestamp = NULL;
              end if;
            end if;
          end loop;
        end;
        $BODY$
LANGUAGE plpgsql VOLATILE
  