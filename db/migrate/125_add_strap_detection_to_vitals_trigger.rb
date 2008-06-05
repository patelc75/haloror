class AddStrapDetectionToVitalsTrigger < ActiveRecord::Migration
  def self.up
    ddl = <<-eos
    create or replace function latest_vitals_trigger_function() returns trigger as $$
    declare
      row record;
    begin
      for row in (select device_strap_status.id from device_strap_status inner join devices_user 
                    on device_strap_status.id = devices_user.device_id where 
                    device_strap_status.is_fastened = 0 and devices_user.user_id = new.user_id) loop
          update latest_vitals set updated_at = now() where id = row.id;
      if NOT FOUND then
          insert into latest_vitals (id, updated_at) values (row.id, now());
      end if;
      end loop;
      return null;
    end;
    $$ language plpgsql;

        eos
    execute ddl
  end

  def self.down
  end
end
