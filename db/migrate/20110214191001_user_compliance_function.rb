class UserComplianceFunction < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
	
    CREATE OR REPLACE FUNCTION battery_charge_periods_function(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone)
    RETURNS void AS
    $$
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
     $$ language plpgsql;
     
     CREATE OR REPLACE FUNCTION user_compliance(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
     RETURNS interval AS
     $$
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
     $$ language plpgsql;     
   eos
   execute ddl
  end
                                    
  def self.down
  end
end
