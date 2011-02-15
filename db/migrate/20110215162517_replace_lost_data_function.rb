class ReplaceLostDataFunction < ActiveRecord::Migration
  def self.up
      ddl = <<-eos       
      CREATE OR REPLACE FUNCTION lost_data_function(
                p_user_id       in integer,
                p_begin_time    in timestamp with time zone,
                p_end_time      in timestamp with time zone,
                p_lost_data_gap in varchar
              ) returns void as $$
      	declare
                 row record;
                 prev_timestamp timestamp with time zone;
                 current_timestamp timestamp with time zone;
               begin
                 for row in (select timestamp from vitals where user_id = p_user_id AND timestamp <= p_end_time AND timestamp >= p_begin_time order by timestamp asc) loop
                   if(prev_timestamp is null) then
                     if((row.timestamp - p_begin_time)::interval > p_lost_data_gap::interval ) then
                       insert into lost_datas (user_id, begin_time, end_time) values (p_user_id, p_begin_time, row.timestamp);
                     end if;
                     prev_timestamp := row.timestamp;
                   else
                     current_timestamp := row.timestamp;
                     if((current_timestamp - prev_timestamp)::interval > p_lost_data_gap::interval ) then
                       insert into lost_datas (user_id, begin_time, end_time) values (p_user_id, prev_timestamp, current_timestamp);
                     end if;  
                     prev_timestamp := current_timestamp;
                   end if;
                 end loop;
                 if((p_end_time - row.timestamp)::interval > p_lost_data_gap::interval ) then
                   insert into lost_datas (user_id, begin_time, end_time) values (p_user_id, row.timestamp, p_end_time);
                 end if; 
              end;
        $$ language plpgsql;

          eos
      execute ddl
    end


    def self.down
    end
  end