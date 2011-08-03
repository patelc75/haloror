CREATE OR REPLACE FUNCTION locked_heartrate_function(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_interval interval)
RETURNS void AS
$$
 declare
   row record;
   start_timestamp timestamp with time zone;
   prev_timestamp timestamp with time zone;
   prev_heartrate smallint;
   l_begin_time timestamp with time zone;
   l_end_time timestamp with time zone;
   locked boolean;
   occurrences integer;
 begin
   prev_heartrate := -15;
   locked := false;
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
   RAISE NOTICE 'HR    Duration         Start                      End          Occurrences';
   RAISE NOTICE '------------------------------------------------------------------------------';
 
   for row in (select heartrate, timestamp from vitals where user_id = p_user_id AND timestamp <= l_end_time AND timestamp >= l_begin_time order by timestamp asc)  
   loop
     --RAISE NOTICE '% % % %', prev_heartrate, row.heartrate, row.timestamp, prev_timestamp-start_timestamp;
     if (prev_heartrate != row.heartrate) then
       if (locked = true) AND (prev_timestamp-start_timestamp > p_interval) AND (prev_heartrate != -1) then
         RAISE NOTICE '%  %  %  %  %', prev_heartrate, prev_timestamp-start_timestamp, start_timestamp, prev_timestamp, occurrences;
         occurrences := 0;
       end if;
       locked = false;
       start_timestamp := row.timestamp;
       occurrences = occurrences + 1;        
     elsif (prev_heartrate = row.heartrate) then
       locked := true;
       occurrences = occurrences + 1;        
     end if;
     prev_timestamp := row.timestamp;
     prev_heartrate := row.heartrate;
   end loop;

   if (prev_heartrate = row.heartrate) AND (row.timestamp-start_timestamp > p_interval) AND (prev_heartrate != -1)  then
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
select * from locked_heartrate_function(1,    now()-interval '1 week', now(), '2 seconds');  --localhost
select * from locked_heartrate_function(1065, now()-interval '1 week', now(), '30 minutes'); --www

select * from locked_heartrates;
delete from locked_heartrates;


insert into vitals (heartrate, timestamp, user_id) values (470, now(), 1);
select id, user_id, heartrate, timestamp from vitals order by timestamp desc;
delete from vitals where id in (24352852, 24352853);