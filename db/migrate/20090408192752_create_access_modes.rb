class CreateAccessModes < ActiveRecord::Migration
  def self.up
    create_table :access_modes, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :mode, :string
  	  t.column :timestamp, :timestamp_with_time_zone
    end
    
    create_table :system_timeouts, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :mode, :string
      t.column :gateway_offline_timeout_min, :integer
      t.column :device_unavailable_timeout_min, :integer
      t.column :strap_off_timeout_min, :integer
      t.timestamps      
    end
    
    create_table :access_mode_statuses, :force => true do |t|
      t.column :id, :primary_key, :null => false
      t.column :device_id, :integer
      t.column :mode, :string
    end
    
    ddl = <<-eos
      create or replace function access_modes_trigger_function() returns trigger as $$
      begin
        UPDATE access_mode_statuses SET mode = new.mode WHERE device_id = new.device_id;
        IF NOT FOUND THEN
          INSERT INTO access_mode_statuses (device_id, mode) VALUES (new.device_id, new.mode);
        END IF;
        return null;
      end;
      $$ language plpgsql;

      create trigger access_modes_trigger after insert on access_modes
         for each row execute procedure access_modes_trigger_function();
    eos
    
    execute ddl
  end

  def self.down
    drop_table :access_mode_statuses
    drop_table :system_timeouts
    drop_table :access_modes
  end
end
