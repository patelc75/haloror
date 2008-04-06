class UpdateAlertTriggers < ActiveRecord::Migration

  def self.up
    ddl = <<-eos
create or replace function device_latest_queries_trigger_function() returns trigger as $$
declare
  v_timestamp device_latest_queries.updated_at%TYPE;
begin
  v_timestamp := case when new.timestamp_server is null then now() else new.timestamp_server end;
  update device_latest_queries 
     set updated_at = v_timestamp
   where id = new.device_id;
  if NOT FOUND then
    insert into device_latest_queries (id, updated_at) values (new.device_id, v_timestamp);
  end if;
  return null;
end;
$$ language plpgsql;
eos
    execute ddl
  end

  def self.down
  end

end
