class AddDevicesUsersToUserStrapStatus < ActiveRecord::Migration

  def self.up
    ddl = <<-eos
create or replace function set_user_strap_status(
  p_device_id    in integer,
  p_is_fastened  in integer
) returns void as $$
declare
  row record;
begin
  for row in (select user_id from devices_users where device_id = p_device_id) loop
    update user_strap_status 
       set is_fastened = p_is_fastened, device_id = p_device_id, updated_at = now() 
     where id = row.user_id;
    if NOT FOUND then
      insert into user_strap_status (id, is_fastened, device_id, updated_at) values (row.user_id, p_is_fastened, p_device_id, now());
    end if;
  end loop;
end;
$$ language plpgsql;
    eos
    execute ddl
  end

  def self.down
    begin
      execute "drop function set_user_strap_status(integer, integer)"
    rescue Exception
    end
  end

end
