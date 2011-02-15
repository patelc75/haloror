class ReplaceBatteryChargePeriodsFunction < ActiveRecord::Migration
  def self.up
      ddl = <<-eos       
      CREATE OR REPLACE FUNCTION battery_charge_periods_function(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone)
        RETURNS void AS
        $$
      	declare
      	   row record;
      	   plugged_timestamp timestamp with time zone;
      	   unplugged_timestamp timestamp with time zone;
      	 begin
      	   for row in (select timestamp, event_type from events where user_id = p_user_id AND timestamp <= p_end_time AND timestamp >= p_begin_time and event_type in ('BatteryPlugged', 'BatteryUnplugged') order by timestamp asc) loop
      	     if(row.event_type = 'BatteryPlugged') then
      	       plugged_timestamp := row.timestamp;
      	       unplugged_timestamp = NULL;
      	     else -- 'BatteryUnplugged'
      	       if (plugged_timestamp is NULL) then --left boundary condition
      		 insert into battery_charge_periods (user_id, begin_time, end_time, duration) values (p_user_id, p_begin_time, row.timestamp, row.timestamp-p_begin_time); 
      	       end if;
      	       if (unplugged_timestamp is NULL and plugged_timestamp is not NULL) then --conditional in case there are 2 unpluggeds in a row
      		 unplugged_timestamp := row.timestamp;
      		 insert into battery_charge_periods (user_id, begin_time, end_time, duration) values (p_user_id, plugged_timestamp, unplugged_timestamp, unplugged_timestamp-plugged_timestamp);
      	       end if;
      	     end if;
      	   end loop;
      	   if(row.event_type = 'BatteryPlugged') then
      	     insert into battery_charge_periods (user_id, begin_time, end_time, duration) values (p_user_id, row.timestamp, p_end_time, p_end_time-row.timestamp);
      	   end if;
      	 end;
        $$ language plpgsql;

          eos
      execute ddl
    end


    def self.down
    end
  end