class UpdateUserStrapStatus < ActiveRecord::Migration

  def self.up
    execute "drop function set_user_strap_status(integer, integer)"  rescue Exception;
    execute "drop table user_strap_status" rescue Exception;

    create_table "device_strap_status", :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :is_fastened, :integer, :null => false
      t.datetime "updated_at", :null => false
    end

    execute "alter table device_strap_status add constraint device_strap_status_id_fk foreign key (id) references devices on delete cascade"
    execute "comment on column device_strap_status.is_fastened is 'A denormalization of the strap_removeds and strap_fasteneds tables. If > 0, it indicates the last event we received was the strap is fastened. If 0, the last event we received is that the strap is NOT fastened'"
    
    ## Create a trigger that captures the latest management query and
    ## updates device_strap_status
    ddl = <<-eos
create or replace function set_device_strap_status(
  p_device_id    in integer,
  p_is_fastened  in integer
) returns void as $$
begin
  update device_strap_status set is_fastened = p_is_fastened, updated_at = now() where id = v_device_id;
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

  def self.down
    drop_table :device_strap_status if
    ActiveRecord::Base.connection.tables.include?(:device_strap_status)
  end

end
