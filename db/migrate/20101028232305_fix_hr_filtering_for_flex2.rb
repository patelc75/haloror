class FixHrFilteringForFlex2 < ActiveRecord::Migration
  def self.up
    ddl = <<-eos
    drop function average_data_record_vitals(integer, varchar, integer, timestamp with time zone);
    drop type averages_vitals;

    create type averages_vitals AS (
      average_heartrate   float,
      average_activity  float,
      ts      timestamp with time zone, 
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
      -- a = average heartrate
      -- b = average activity
      -- c = other columns like average hrv, orientation
      -- outer SQL = fetch columns from a, b, c and ROUND them to return the result set
      -- ts = timestamp for each interval. only in the outer query
      query_vitals := 'SELECT ROUND(a.heart,1) AS average_heartrate, ROUND(b.act,1) AS average_activity, ' || quote_literal(et) || ' AS ts, ROUND(c.avghrv,0) AS average_hrv, ROUND(c.avgor,0) AS average_orientation FROM ' ||
      ' (SELECT AVG(heartrate) AS heart FROM vitals WHERE timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ' AND user_id = ' || p_user_id || ' AND heartrate <> -1) a, ' ||
      ' (SELECT AVG(activity) AS act FROM vitals WHERE timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ' AND user_id = ' || p_user_id || ' AND activity <> -1) b, ' ||
      ' (SELECT AVG(hrv) AS avghrv, AVG(orientation) AS avgor FROM vitals WHERE timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ' AND user_id = ' || p_user_id || ' AND (activity <> -1 OR heartrate <> -1)) c ';
      --
      -- old query
      --
      -- query_vitals := 'SELECT avg(heartrate) as average_heartrate, avg(activity) as average_activity, ' || quote_literal(et) || ' as ts, avg(hrv) as average_hrv, avg(orientation) as average_orientation from vitals ' ||
      --     ' where activity <> -1 AND user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
      for i in 1..p_num_points loop
        EXECUTE query_vitals into averages_row;
        ct := et;
        et := ct + ("interval"(p_interval));
        -- a = average heartrate
        -- b = average activity
        -- c = other columns like average hrv, orientation
        -- outer SQL = fetch columns from a, b, c and ROUND them to return the result set
        -- ts = timestamp for each interval. only in the outer query
        query_vitals := 'SELECT ROUND(a.heart,1) AS average_heartrate, ROUND(b.act,1) AS average_activity, ' || quote_literal(et) || ' AS ts, ROUND(c.avghrv,0) AS average_hrv, ROUND(c.avgor,0) AS average_orientation FROM ' ||
        ' (SELECT AVG(heartrate) AS heart FROM vitals WHERE timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ' AND user_id = ' || p_user_id || ' AND heartrate <> -1) a, ' ||
        ' (SELECT AVG(activity) AS act FROM vitals WHERE timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ' AND user_id = ' || p_user_id || ' AND activity <> -1) b, ' ||
        ' (SELECT AVG(hrv) AS avghrv, AVG(orientation) AS avgor FROM vitals WHERE timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ' AND user_id = ' || p_user_id || ' AND (activity <> -1 OR heartrate <> -1)) c ';
        --
        -- old query
        --
        -- query_vitals := 'select avg(heartrate) as average_heartrate, avg(activity) as average_activity, ' || quote_literal(et) || ' as ts, avg(hrv) as average_hrv, avg(orientation) as average_orientation from vitals ' ||
        --   ' where activity <> -1 AND user_id = ' || p_user_id || ' AND (timestamp >= ' || quote_literal(ct) || ' AND timestamp < ' || quote_literal(et) || ')';
        --
        RETURN NEXT averages_row;
      end loop;
    end;

    $$ language plpgsql;
    eos

    execute ddl
  end

  def self.down
  end
end    
