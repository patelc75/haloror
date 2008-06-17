class AddFunctionsFoAverages < ActiveRecord::Migration
  def self.up
    
    ddl = <<-eos
    
    create type averages_vitals AS (
    	average_heartrate 	float,
    	average_activity 	float,
    	ts			timestamp
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
    	query_vitals := 'select avg(heartrate) as average_heartrate, avg(activity) as average_activity, ' || quote_literal(et) || ' as ts from vitals ' ||
    			' where user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
    	for i in 1..p_num_points loop
    		EXECUTE query_vitals into averages_row;
    		ct := et;
    		et := ct + ("interval"(p_interval));
    		query_vitals := 'select avg(heartrate) as average_heartrate, avg(activity) as average_activity, ' || quote_literal(et) || ' as ts from vitals ' ||
    			' where user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
    		RETURN NEXT averages_row;
    	end loop;

    end;

    $$ language plpgsql;
    create type averages AS (
    	average 	float,
    	ts			timestamp
    );
    create or replace function average_data_record(
      p_user_id    in integer,
      p_interval   in varchar,
      p_num_points  in integer, 
    	p_start_time in timestamp with time zone,
    	p_table_name in varchar,
    	p_column_name in varchar
    ) returns setof averages
    as $$

    declare
    	averages_row averages%rowtype;
    	query_averages  text;
    	ct timestamp := p_start_time;
    	et timestamp := ct + ("interval"(p_interval));
    begin
    	query_averages := 'select avg(' || p_column_name ||') as average, ' || quote_literal(et) || ' as ts from ' || p_table_name ||
    			' where user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
    	for i in 1..p_num_points loop
    		EXECUTE query_averages into averages_row;
    		ct := et;
    		et := ct + ("interval"(p_interval));
    		query_averages := 'select avg(' || p_column_name ||') as average, ' || quote_literal(et) || ' as ts from ' || p_table_name ||
    				' where user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
    		RETURN NEXT averages_row;
    	end loop;

    end;


    $$ language plpgsql;


    create type sums AS (
    	sum_result 	float,
    	ts			timestamp
    );
    create or replace function sum_data_record(
      p_user_id    in integer,
      p_interval   in varchar,
      p_num_points  in integer, 
    	p_start_time in timestamp with time zone,
    	p_table_name in varchar,
    	p_column_name in varchar
    ) returns setof sums
    as $$

    declare
    	sums_row sums%rowtype;
    	query_sums  text;
    	ct timestamp := p_start_time;
    	et timestamp := ct + ("interval"(p_interval));
    begin
    	query_sums := 'select sum(' || p_column_name ||') as sum_result, ' || quote_literal(et) || ' as ts from ' || p_table_name ||
    			' where user_id = ' || p_user_id || ' AND (begin_timestamp >= ' || quote_literal(ct) || ' AND begin_timestamp < ' || quote_literal(et) || ')';
    	for i in 1..p_num_points loop
    		EXECUTE query_sums into sums_row;
    		ct := et;
    		et := ct + ("interval"(p_interval));
    		query_sums := 'select sum(' || p_column_name ||') as sum_result, ' || quote_literal(et) || ' as ts from ' || p_table_name ||
    				' where user_id = ' || p_user_id || ' AND (begin_timestamp >= ' || quote_literal(ct) || ' AND begin_timestamp < ' || quote_literal(et) || ')';
    		RETURN NEXT sums_row;
    	end loop;

    end;

    $$ language plpgsql;
    
    eos
    execute ddl
  end

  def self.down
    ddl = <<-eos
    drop type averages;
    drop type sums;
    drop type averages_vitals;
    eos
    execute ddl
  end
end
