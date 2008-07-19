class CreateLatestVitals3 < ActiveRecord::Migration

  def self.up
    begin
      drop_table "latest_vitals"
    rescue Exception
    end

    create_table "latest_vitals", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.datetime "updated_at", :null => false
    end

    execute "alter table latest_vitals add constraint latest_vitals_id_fk foreign key (id) references devices on delete cascade"

    ## Create a trigger that captures the latest vitals
    ## information. Since a device can belong to multiple users, we
    ## record that the specified device is in range.
    ddl = <<-eos
create or replace function latest_vitals_trigger_function() returns trigger as $$
declare
  row record;
begin
  for row in (select device_id from devices_users where user_id = new.user_id) loop
    update latest_vitals set updated_at = now() where id = row.device_id;
    if NOT FOUND then
      insert into latest_vitals (id, updated_at) values (row.device_id, now());
    end if;
  end loop;
  return null;
end;
$$ language plpgsql;

    eos
    execute ddl
  end

end
