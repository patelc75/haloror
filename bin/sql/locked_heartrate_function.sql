CREATE OR REPLACE FUNCTION locked_heartrate_function(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_interval interval)
RETURNS void AS
$$
 declare
   row record;
   start_timestamp timestamp with time zone;
   prev_timestamp timestamp with time zone;
   prev_heartrate smallint;
   prev_strap_status boolean;
   l_begin_time timestamp with time zone;
   l_end_time timestamp with time zone;
   locked boolean;      
   strap_invalid boolean;
   occurrences integer;
 begin
   prev_heartrate := -15;
   prev_strap_status = false;
   locked := false;       
   strap_invalid := false;
   occurrences := 0;
   if p_begin_time IS NULL then
     l_begin_time := now() - interval '1 week';
   else 
     l_begin_time := p_begin_time;       
   end if;
   if p_end_time IS NULL then
     l_end_time := now();        
   else
     l_end_time := p_end_time;
   end if;                 
   RAISE NOTICE 'Start %, End %, user_id = %', l_begin_time, l_end_time, p_user_id;
   RAISE NOTICE 'HR  Duration         Start                      End          Occurrences';
   RAISE NOTICE '------------------------------------------------------------------------------';
 
   for row in (select heartrate, timestamp, strap_status from vitals where user_id = p_user_id AND timestamp <= l_end_time AND timestamp >= l_begin_time order by timestamp asc)  
   loop
     if (prev_heartrate != row.heartrate) OR (strap_invalid = true AND row.strap_status = false) OR (prev_heartrate = -1 AND row.strap_status != prev_strap_status) then
       if (locked = true) AND (prev_timestamp-start_timestamp > p_interval) AND NOT (prev_heartrate = -1 AND strap_invalid = false) then
         RAISE NOTICE '%  %  %  %  %', prev_heartrate, prev_timestamp-start_timestamp, start_timestamp, prev_timestamp, occurrences;
         strap_invalid := false;
       end if;
       locked = false;
       if (row.heartrate = -1) AND (row.strap_status = true) then
         strap_invalid := true;  --HR should not be -1 when strap is fastened
       end if;
       start_timestamp := row.timestamp;
       occurrences = 1;        
     elsif (prev_heartrate = row.heartrate) then
       locked := true;
       occurrences = occurrences + 1;        
     end if;
     prev_timestamp    := row.timestamp;
     prev_heartrate    := row.heartrate;
     prev_strap_status := row.strap_status;
   end loop;

   if (prev_heartrate = row.heartrate) AND (row.timestamp-start_timestamp > p_interval) AND NOT(row.heartrate = -1 AND strap_invalid = false) then
     RAISE NOTICE '%  %  %  %  %', row.heartrate, row.timestamp-start_timestamp, start_timestamp, row.timestamp, occurrences;
   end if;
 end;
$$ 
LANGUAGE 'plpgsql' VOLATILE
COST 100;


--The RAISE statements above replaced these INSERTs
      --insert into locked_heartrates (user_id, locked_heartrate, begin_time, end_time) values (p_user_id, p_locked_heartrate, start_timestamp, prev_timestamp);
    --insert into locked_heartrates (user_id, locked_heartrate, begin_time, end_time) values (p_user_id, p_locked_heartrate, start_timestamp, row.timestamp);

    
------------ SQL commands to help debug the above Pg function -----------
--parameters: user_id, locked heartarate, begin, end, interval
select * from locked_heartrate_function(470,  now()-interval '1 week', now(), '30 minutes'); --LDEV
select * from locked_heartrate_function(1,    now()-interval '1 week', now(), '0 seconds');  --localhost
select * from locked_heartrate_function(1065, now()-interval '1 week', now(), '30 minutes'); --www   

select * from locked_heartrate_function(1247,  timestamp '2010-11-18 19:15:45'-interval '1 week', now(), '30 minutes');

select * from locked_heartrates;
delete from locked_heartrates;


insert into vitals (heartrate, timestamp, user_id, strap_status) values (5, now(), 1, true);
select id, user_id, heartrate, strap_status, timestamp from vitals order by timestamp desc;
delete from vitals where id in (24352852, 24352853);