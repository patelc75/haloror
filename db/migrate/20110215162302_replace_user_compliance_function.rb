class ReplaceUserComplianceFunction < ActiveRecord::Migration
  def self.up
      ddl = <<-eos
      DROP FUNCTION user_compliance(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar);
       
      CREATE OR REPLACE FUNCTION usage_minus_lost_data_gaps_and_battery_charge(p_user_id integer, p_begin_time timestamp with time zone, p_end_time timestamp with time zone, p_lost_data_gap varchar)
       RETURNS double precision AS
       $$
     	 declare
     	   row record;
     	   battery_charge_duration interval;
     	   lost_data_duration interval;
     	   usage_minus_lost_data_gaps_and_battery_charge interval;
     	 begin
     	   delete from battery_charge_periods where user_id = p_user_id;
     	   delete from lost_datas where user_id = p_user_id;

     	   select * into row from battery_charge_periods_function(p_user_id, p_begin_time, p_end_time);
     	   select * into row from lost_data_function(p_user_id, p_begin_time, p_end_time, p_lost_data_gap);

     	   select sum(duration) into battery_charge_duration from battery_charge_periods where user_id = p_user_id;
     	   select sum(end_time-begin_time) into lost_data_duration from lost_datas where user_id = p_user_id;
     	   if battery_charge_duration is NULL then
     	     battery_charge_duration = interval '0 seconds';
     	   end if;

     	   if lost_data_duration is NULL then
     	     lost_data_duration = interval '0 seconds';
     	   end if;

     	   RAISE NOTICE 'battery_charge_duration = %', date_trunc('second', battery_charge_duration);
     	   RAISE NOTICE 'lost_data_duration = %',  date_trunc('second', lost_data_duration);
     	   RAISE NOTICE 'total period = %', date_trunc('second', p_end_time - p_begin_time); 
     	   usage_minus_lost_data_gaps_and_battery_charge = date_trunc('second', p_end_time - (p_begin_time + battery_charge_duration + lost_data_duration));   
     	   RAISE NOTICE 'total usage = total period - battery_charge_duration - lost_data_duration = %', usage_minus_lost_data_gaps_and_battery_charge;
         RAISE NOTICE 'total usage = total period - battery_charge_duration - lost_data_duration = % hours', extract('epoch' from usage_minus_lost_data_gaps_and_battery_charge) / 3600;

     	   return extract('epoch' from usage_minus_lost_data_gaps_and_battery_charge) / 3600;
     	 end;
       $$ language plpgsql;

          eos
      execute ddl
    end


    def self.down
    end
  end