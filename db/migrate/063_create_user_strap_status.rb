class CreateUserStrapStatus < ActiveRecord::Migration

  def self.up
    create_table "user_strap_status", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :is_fastened, :integer, :null => false
      t.datetime "updated_at", :null => false
    end

    execute "alter table user_strap_status add constraint user_strap_status_id_fk foreign key (id) references users on delete cascade"
    execute "comment on column user_strap_status.is_fastened is 'A denormalization of the strap_removeds and strap_fasteneds tables. If > 0, it indicates the last event we received was the strap is fastened. If 0, the last event we received is that the strap is NOT fastened'"
    
    ## Create a trigger that captures the latest management query and
    ## updates user_strap_status
    ddl = <<-eos
create or replace function set_user_strap_status(
  p_device_id    in integer,
  p_is_fastened  in integer
) returns void as $$
declare
  v_user_id  integer;
begin
  select user_id into v_user_id from devices where id = p_device_id;
  if v_user_id is null then
    raise exception 'Could not find device with ID=%', p_device_id;
  end if;

  update user_strap_status set is_fastened = p_is_fastened, updated_at = now() where id = v_user_id;
  if NOT FOUND then
    insert into user_strap_status (id, is_fastened, updated_at) values (v_user_id, p_is_fastened, now());
  end if;
end;
$$ language plpgsql;

create or replace function user_strap_status_fasteneds_trigger_function() returns trigger as $$
begin
  perform set_user_strap_status(new.device_id, 1);
  return null;
end;
$$ language plpgsql;

create trigger user_strap_status_fasteneds_trigger after insert on strap_fasteneds
   for each row execute procedure user_strap_status_fasteneds_trigger_function();

create or replace function user_strap_status_removeds_trigger_function() returns trigger as $$
begin
  perform set_user_strap_status(new.device_id, 0);
  return null;
end;
$$ language plpgsql;

create trigger user_strap_status_removeds_trigger after insert on strap_removeds
   for each row execute procedure user_strap_status_removeds_trigger_function();

    eos
    execute ddl
  end

  def self.down
    begin
      drop_table "user_strap_status"
    rescue Exception
    end
    
    begin
      execute "drop function user_strap_status_fasteneds_trigger_function()"
    rescue Exception
    end

    begin
      execute "drop function user_strap_status_removeds_trigger_function()"
    rescue Exception
    end

    begin
      execute "drop trigger user_strap_status_fasteneds_trigger on strap_fasteneds"
    rescue Exception
    end

    begin
      execute "drop trigger user_strap_status_removeds_trigger on strap_removeds"
    rescue Exception
    end

  end

end
