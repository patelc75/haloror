class CreateDeviceLatestQueries < ActiveRecord::Migration

  def self.up
    create_table "device_latest_queries", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.datetime "updated_at", :null => false
    end

    execute "alter table device_latest_queries add constraint device_latest_queries_id_fk foreign key (id) references devices on delete cascade"

    ## Create a trigger that captures the latest management query and
    ## updates device_latest_queries
    ddl = <<-eos
create or replace function device_latest_queries_trigger_function() returns trigger as $$
begin
  update device_latest_queries set updated_at = now() where id = new.device_id;
  if NOT FOUND then
    insert into device_latest_queries (id, updated_at) values (new.device_id, case when new.timestamp_server is null then now() else new.timestamp_server end);
  end if;
  return null;
end;
$$ language plpgsql;

create trigger device_latest_queries_trigger after insert on mgmt_queries
   for each row execute procedure device_latest_queries_trigger_function();
    eos
    execute ddl
  end

  def self.down
    begin
      drop_table "device_latest_queries"
    rescue Exception
    end
    
    begin
      execute "drop function device_latest_queries_trigger_function()"
    rescue Exception
    end

    begin
      execute "drop trigger device_latest_queries_trigger on mgmt_queries"
    rescue Exception
    end
  end

end
