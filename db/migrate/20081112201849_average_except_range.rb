class AverageExceptRange < ActiveRecord::Migration
  def self.up
    ddl = <<-eos
    
    create or replace function average_except_range(
      p_user_id    in integer,
      p_min in float,
      p_max in float,
      p_interval   in varchar,
      p_start_time in timestamp with time zone
    ) returns float
    as $$

    declare
      row record;
      row2 record;
      average float;
      num integer;
      begin_timestamp timestamp with time zone;
      end_timestamp timestamp with time zone;
      prev_timestamp timestamp with time zone;
      query_average  text;
      ct timestamp := p_start_time;
      et timestamp := ct + ("interval"(p_interval));
    begin
    
      prev_timestamp := p_start_time;
      average := 0;
      num := 0;
      for row in (select timestamp from skin_temps where skin_temp > p_max OR skin_temp < p_min ORDER BY timestamp asc) loop
        begin_timestamp := row.timestamp - ("interval"(p_interval));
        if(prev_timestamp < begin_timestamp) then
           for row2 in select avg(skin_temp) as avg_skin_temp from skin_temps where timestamp > prev_timestamp AND timestamp < begin_timestamp loop
             if row2.avg_skin_temp IS NOT NULL then
               average := average + row2.avg_skin_temp;
               num := num + 1;
             end if;
           end loop;
        end if;
        prev_timestamp := row.timestamp + ("interval"(p_interval));
      end loop;
      if num > 0 then
        average := average / num;
      end if;
      RETURN average;
    end;

    $$ language plpgsql;
    
    
    create or replace function average_except_strap_removed(
      p_user_id    in integer,
      p_interval   in varchar,
      p_start_time in timestamp with time zone
    ) returns float
    as $$

    declare
      row record;
      row2 record;
      average float;
      num integer;
      begin_timestamp timestamp with time zone;
      end_timestamp timestamp with time zone;
      prev_timestamp timestamp with time zone;
      query_average  text;
    begin
    
      prev_timestamp := p_start_time;
      average := 0;
      num := 0;
      for row in (select timestamp from strap_removeds where timestamp > p_start_time ORDER BY timestamp asc) loop
        begin_timestamp := row.timestamp - ("interval"(p_interval));
        if(prev_timestamp < begin_timestamp) then
           for row2 in select avg(skin_temp) as avg_skin_temp from skin_temps where timestamp > prev_timestamp AND timestamp < begin_timestamp loop
             if row2.avg_skin_temp IS NOT NULL then
               average := average + row2.avg_skin_temp;
               num := num + 1;
             end if;
           end loop;
        end if;
        prev_timestamp := row.timestamp + ("interval"(p_interval));
      end loop;
      if num > 0 then
        average := average / num;
      end if;
      RETURN average;
    end;

    $$ language plpgsql;
    
    eos
    execute ddl
  end

  def self.down
  end
end
