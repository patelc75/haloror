class CreateFunctionDeviceNotWornFunction < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
	  	
		CREATE OR REPLACE FUNCTION device_not_worn_function(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone)
		RETURNS void AS
		$$
	        declare
	          row record;
	          start_timestamp timestamp with time zone;
	          prev_timestamp timestamp with time zone;
	          prev_heartrate smallint;
	        begin
		   prev_heartrate := 0;
	           if p_begin_time IS NULL then
	             for row in (select heartrate, timestamp from vitals where user_id = p_user_id AND timestamp <= p_end_time order by timestamp asc) loop
	              if (prev_heartrate > -1) AND (row.heartrate = -1) then
	                start_timestamp := row.timestamp;
	              elsif (prev_heartrate = -1) AND (row.heartrate > -1) then
					insert into strap_not_worns (user_id, begin_time, end_time) values (p_user_id, start_timestamp, prev_timestamp);
	              end if;
	              prev_timestamp := row.timestamp;
	              prev_heartrate := row.heartrate;
	            end loop;
	          else
	            for row in (select heartrate, timestamp from vitals where user_id = p_user_id AND timestamp <= p_end_time AND timestamp >= p_begin_time order by timestamp asc) loop
	              if (prev_heartrate > -1) AND (row.heartrate = -1) then
	                start_timestamp := row.timestamp;
	              elsif (prev_heartrate = -1) AND (row.heartrate > -1) then
					insert into strap_not_worns (user_id, begin_time, end_time) values (p_user_id, start_timestamp, prev_timestamp);
	              end if;
	              prev_timestamp := row.timestamp;
	              prev_heartrate := row.heartrate;
	            end loop;
	          end if;
	          end;
		$$ 
	  LANGUAGE 'plpgsql' VOLATILE
	  COST 100;
   eos
    
    execute ddl
    
  end

  def self.down
	ddl = <<-eos

		DROP FUNCTION device_not_worn_function(integer, timestamp with time zone, timestamp with time zone);
    eos
    
    execute ddl  
  end
end
