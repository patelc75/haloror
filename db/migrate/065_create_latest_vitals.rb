class CreateLatestVitals < ActiveRecord::Migration

  def self.up
    create_table "latest_vitals", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.datetime "updated_at", :null => false
    end

    execute "alter table latest_vitals add constraint latest_vitals_id_fk foreign key (id) references users on delete cascade"

    ## Create a trigger that captures the latest vitals information
    ddl = <<-eos
create or replace function latest_vitals_trigger_function() returns trigger as $$
begin
  update latest_vitals set updated_at = now() where id = new.user_id;
  if NOT FOUND then
    insert into latest_vitals (id, updated_at) values (new.user_id, now());
  end if;
  return null;
end;
$$ language plpgsql;

create trigger latest_vitals_trigger after insert on vitals
   for each row execute procedure latest_vitals_trigger_function();
    eos
    execute ddl
  end

  def self.down
    begin
      drop_table "latest_vitals"
    rescue Exception
    end
    
    begin
      execute "drop function latest_vitals_trigger_function()"
    rescue Exception
    end

    begin
      execute "drop trigger latest_vitals_trigger on vitals"
    rescue Exception
    end
  end

end
