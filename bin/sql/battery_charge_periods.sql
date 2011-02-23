/* run  the lost_data (vitals) query --------------------------------------------------------------------------------- */
select * from vitals where user_id = 1 order by timestamp asc limit 1000;
select * from lost_data_function(1, '2011-02-16', now(), '1 second');
select *,end_time-begin_time as duration from lost_datas where user_id = 232;
select sum(end_time-begin_time) from lost_datas where user_id = 1;
delete from lost_datas;
insert into vitals (timestamp, user_id) values ('2011-02-16 02:48:38.88439+00', 1);

/* refs #4183 queries for calculate battery periods ------------------------------------------------------------------- */
select * from events where event_type in ('StrapFastened', '') and user_id = 1 order by timestamp asc;
select * from strap_fastened_periods_function(1, '2009-10-10', now());
select * from events where event_type in ('BatteryPlugged', 'BatteryUnplugged') and user_id = 1 and timestamp >= '2011-01-24 00:06:00+00' and timestamp <= '2011-01-31 00:06:00+00' order by timestamp asc;
select * from strap_fastened_periods_function(1, '2009-10-08 08:26:05+00', '2009-10-08 8:36:05+00');
insert into events (user_id, timestamp, event_type) values (1, '2009-10-08 9:37:05+00', 'BatteryUnplugged');
delete from events where timestamp = '2009-10-08 9:37:05+00';

delete from strap_fastened_periods;
select * from strap_fastened_periods where user_id = 1;
select * from lost_datas where user_id = 177;
delete from strap_fastened_periods where user_id = 177;
select sum(duration) from strap_fastened_periods where user_id = 177;;


select * from usage_minus_lost_data_gaps_and_battery_charge(232, '2011-02-15', '2011-02-17', '90 seconds');
select * from usage_minus_lost_data_gaps_and_battery_charge_multiple(array_agg(select id from users limit 2), '2011-02-08', now(), '90 seconds');
select array_agg(any (select id from users limit 2));
select array_agg((select id from users limit 2));
select array_agg(id) from users limit 2;

select * from test_array_agg("{13,5}");

CREATE OR REPLACE FUNCTION test_array_agg(user_ids integer[])
  RETURNS void AS
$$
declare
begin
FOR i in array_lower(user_ids, 1) .. array_upper(user_ids, 1) LOOP
  Raise Notice '%', user_ids[i]::integer;
  --select * from usage_minus_lost_data_gaps_and_battery_charge(user_ids[i]::integer, '2011-02-08', now(), '90 seconds');
END LOOP;
end
$$
  LANGUAGE plpgsql;


--http://stackoverflow.com/questions/3848679/sql-error-more-than-one-row-returned-by-a-subquery-used-as-an-expression

select date_trunc('second', usage_minus_lost_data_gaps_and_battery_charge) from usage_minus_lost_data_gaps_and_battery_charge(261, '2011-02-08', now(), '90 seconds');
select extract(usage_minus_lost_data_gaps_and_battery_charge from usage_minus_lost_data_gaps_and_battery_charge(261, '2011-02-08', now(), '90 seconds'));
select extract(epoch from '2007-09-22 17:00'::timestamp);
select to_char('6 days 19:18:21'::interval, 'HH24'+'D'*24);
select extract('epoch' from '6 days 19:18:21'::interval) / 3600;  

/* instructions for brandon ------------------------------------------------------------------- */
select * from usage_minus_lost_data_gaps_and_battery_charge(1, '2011-02-08', now(), '90 seconds');
select * from strap_fastened_periods where user_id = 1;
select *,end_time-begin_time as duration from lost_datas where user_id = 1;

/* General queries for debuging --------------------------------------------------------------------------------------- */
select *,end_time-begin_time as duration from lost_datas where user_id = 78 
select * from strap_fastened_periods_function(1, '2009-01-01', now());
select usage from usage(1, '2009-10-10', now(), '90 seconds');
CREATE TABLE strap_fastened_periods(id serial primary key, user_id integer, begin_time timestamp with time zone, end_time timestamp with time zone, duration interval);

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

---------CreateStrapFastenedPeriodsFunction migration --------------------------

      CREATE OR REPLACE FUNCTION strap_fastened_periods_function(
                p_user_id       in integer,
                p_begin_time    in timestamp with time zone,
                p_end_time      in timestamp with time zone
              ) returns void as $$
          	declare
          	   row record;
          	   fastened_timestamp timestamp with time zone;
          	   unfastened_timestamp timestamp with time zone;
          	   no_data_flag boolean;
          	 begin
          	   no_data_flag = true;  
          	   for row in (select timestamp, event_type from events where user_id = p_user_id AND timestamp <= p_end_time AND timestamp >= p_begin_time and event_type in ('StrapFastened', 'StrapRemoved') order by timestamp asc) loop
    	           no_data_flag = false;
          	     if(row.event_type = 'StrapFastened') then
          	       fastened_timestamp := row.timestamp;
          	       unfastened_timestamp = NULL;      	       
          	     else -- 'StrapFastened'
          	       if (fastened_timestamp is NULL) then --left boundary condition
          		 insert into strap_fastened_periods (user_id, begin_time, end_time, duration) values (p_user_id, p_begin_time, row.timestamp, row.timestamp-p_begin_time); 
          		 --RAISE NOTICE '1 fastened_timestamp = %, unfastened_timestamp = %, row.timestamp = %', fastened_timestamp, unfastened_timestamp, row.timestamp;
          	       end if;
          	       if (unfastened_timestamp is NULL and fastened_timestamp is not NULL) then --conditional in case there are 2 unpluggeds in a row
          		 unfastened_timestamp := row.timestamp;
          		 insert into strap_fastened_periods (user_id, begin_time, end_time, duration) values (p_user_id, fastened_timestamp, unfastened_timestamp, unfastened_timestamp-fastened_timestamp);
          		 --RAISE NOTICE '2 fastened_timestamp = %, unfastened_timestamp = %, row.timestamp = %', fastened_timestamp, unfastened_timestamp, row.timestamp;
          	       end if;
          	     end if;
          	   end loop;
          	   if(row.event_type = 'StrapFastened') then
          	     insert into strap_fastened_periods (user_id, begin_time, end_time, duration) values (p_user_id, row.timestamp, p_end_time, p_end_time-row.timestamp);
          	     --RAISE NOTICE '3 fastened_timestamp = %, unfastened_timestamp = %, row.timestamp = %, row.event_type = %', fastened_timestamp, unfastened_timestamp, row.timestamp, row.event_type;
          	   end if;
               --RAISE NOTICE '3.1 no_data_flag = %', no_data_flag;
          	   if(no_data_flag = true) then   
          	     select timestamp, event_type into row from events where user_id = p_user_id AND timestamp <p_begin_time and event_type in ('StrapFastened', 'StrapRemoved') order by timestamp desc limit 1;  
          	     --RAISE NOTICE '3.2 row = %', row;    
          	     if(row is not null and row.event_type = 'StrapFastened') then
    		insert into strap_fastened_periods (user_id, begin_time, end_time, duration) values (p_user_id, p_begin_time, p_end_time, p_end_time-p_begin_time);
    		--RAISE NOTICE '4 fastened_timestamp = %, unfastened_timestamp = %, row.timestamp = %, row.event_type = %', fastened_timestamp, unfastened_timestamp, row.timestamp, row.event_type;
    	     end if;
               end if;   
          	 end;  
        $$ language plpgsql; 

