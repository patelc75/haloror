class CreateStrapFastenedPeriodsFunction < ActiveRecord::Migration
  def self.up
      ddl = <<-eos             
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

          eos
      execute ddl
    end


    def self.down
    end
  end