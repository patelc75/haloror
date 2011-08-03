class CreateFunctionLockedHeartrateFunction < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
	  	
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
   eos
    
    execute ddl
    
  end

  def self.down
  end
end
