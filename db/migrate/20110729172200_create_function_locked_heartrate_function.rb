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
   eos
    
    execute ddl
    
  end

  def self.down
  end
end