class ModifyAverageVitalsIncludeHrvOrientation < ActiveRecord::Migration
  def self.up
    ddl = <<-eos
    drop function average_data_record_vitals(integer, varchar, integer, timestamp with time zone);
    drop type averages_vitals;
    
    create type averages_vitals AS (
    	average_heartrate 	float,
    	average_activity 	float,
    	ts			timestamp, 
    	average_hrv float,
    	average_orientation float
    );
    create or replace function average_data_record_vitals(
      p_user_id    in integer,
      p_interval   in varchar,
      p_num_points  in integer, 
    	p_start_time in timestamp with time zone
    ) returns setof averages_vitals
    as $$

    declare
    	averages_row averages_vitals%rowtype;
    	query_vitals  text;
    	ct timestamp := p_start_time;
    	et timestamp := ct + ("interval"(p_interval));
    begin
    	query_vitals := 'select avg(heartrate) as average_heartrate, avg(activity) as average_activity, ' || quote_literal(et) || ' as ts, avg(hrv) as average_hrv, avg(orientation) as average_orientation from vitals ' ||
    			' where user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
    	for i in 1..p_num_points loop
    		EXECUTE query_vitals into averages_row;
    		ct := et;
    		et := ct + ("interval"(p_interval));
    		query_vitals := 'select avg(heartrate) as average_heartrate, avg(activity) as average_activity, ' || quote_literal(et) || ' as ts, avg(hrv) as average_hrv, avg(orientation) as average_orientation from vitals ' ||
    			' where user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
    		RETURN NEXT averages_row;
    	end loop;

    end;

    $$ language plpgsql;
    eos
    execute ddl
  end

  def self.down
    ddl = <<-eos
    drop function average_data_record_vitals(integer, varchar, integer, timestamp with time zone);
    drop type averages_vitals;
    eos
    execute ddl;
  end
end
