class RecreateDeviceStrapStatusRemovedTrigger < ActiveRecord::Migration
  def self.up
    begin
      execute "drop trigger device_strap_status_removeds_trigger on strap_removeds"
    rescue Exception
    end
    ddl = <<-eos
    create trigger device_strap_status_removeds_trigger after insert on strap_removeds
       for each row execute procedure device_strap_status_removeds_trigger_function();

        eos
        execute ddl
  end

  def self.down
  end
end
