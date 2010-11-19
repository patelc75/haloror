class CreateOrientationFunction < ActiveRecord::Migration
  def self.up
      ddl = <<-eos
      create or replace function orientation_threshold_function(
        p_user_id      in integer,
        p_begin_time   in timestamp with time zone,
        p_end_time     in timestamp with time zone,
        p_gap 		in varchar,
        p_min_angle 	in integer,
        p_max_angle	in integer
      ) returns void as $$
      declare
        row record;
        prev_timestamp timestamp with time zone;
        current_timestamp timestamp with time zone;
        interval_begin_timestamp timestamp with time zone;
        interval_restart_bool boolean; 
        query_begin_time timestamp with time zone;
      begin
       query_begin_time := p_begin_time;
       if query_begin_time IS NULL then
         query_begin_time := '1970-01-01 00:00:00';
       end if;
       for row in (select timestamp, orientation from vitals where user_id = p_user_id AND timestamp <= p_end_time AND timestamp >= query_begin_time order by timestamp asc) loop
        if(prev_timestamp is NULL) then
          prev_timestamp := row.timestamp;
          interval_begin_timestamp := row.timestamp;
          interval_restart_bool = false;
        else
          current_timestamp := row.timestamp; 
          if interval_restart_bool = true then
            interval_begin_timestamp = current_timestamp;
            interval_restart_bool = false;
          end if;
          if(row.orientation <> 0 and (row.orientation < p_min_angle or row.orientation > p_max_angle)) then
            if((current_timestamp - interval_begin_timestamp)::interval >= p_gap::interval ) then   
              insert into orientation_thresholds (user_id, begin_time, end_time, min_angle, max_angle, created_at) values (p_user_id, interval_begin_timestamp, current_timestamp, p_min_angle, p_max_angle, now());                  
            end if;
            interval_restart_bool = true;                
          end if;
          prev_timestamp := current_timestamp;
        end if; 
       end loop;
	      if((current_timestamp - interval_begin_timestamp)::interval > p_gap::interval ) then   
          insert into orientation_thresholds (user_id, begin_time, end_time, min_angle, max_angle, created_at) values (p_user_id, interval_begin_timestamp, current_timestamp, p_min_angle, p_max_angle, now());                  
	      end if;
      end;
      $$ language plpgsql;  
          eos
      execute ddl
    end


    def self.down
    end  
end