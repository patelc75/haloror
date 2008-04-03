class FixUpdateUserStrapStatusPlsql < ActiveRecord::Migration

  def self.up
    execute "drop trigger device_strap_status_fasteneds_trigger on strap_fasteneds" rescue Exception
    execute "drop trigger device_strap_status_removeds_trigger on strap_removeds" rescue Exception
    execute "drop trigger user_strap_status_fasteneds_trigger on strap_fasteneds" rescue Exception
    execute "drop trigger user_strap_status_removeds_trigger ON strap_removeds" rescue Exception
    ddl = <<-eos
create or replace function set_device_strap_status(
  p_device_id    in integer,
  p_is_fastened  in integer
) returns void as $$
begin
  update device_strap_status set is_fastened = p_is_fastened, updated_at = now() where id = p_device_id;
  if NOT FOUND then
    insert into device_strap_status (id, is_fastened, updated_at) values (p_device_id, p_is_fastened, now());
  end if;
end;
$$ language plpgsql;

create or replace function device_strap_status_fasteneds_trigger_function() returns trigger as $$
begin
  perform set_device_strap_status(new.device_id, 1);
  return null;
end;
$$ language plpgsql;

create trigger device_strap_status_fasteneds_trigger after insert on strap_fasteneds
   for each row execute procedure device_strap_status_fasteneds_trigger_function();

create or replace function device_strap_status_removeds_trigger_function() returns trigger as $$
begin
  perform set_device_strap_status(new.device_id, 0);
  return null;
end;
$$ language plpgsql;

create trigger device_strap_status_removeds_trigger after insert on strap_removeds
   for each row execute procedure device_strap_status_removeds_trigger_function();
 
    eos
    execute ddl

  end

end
