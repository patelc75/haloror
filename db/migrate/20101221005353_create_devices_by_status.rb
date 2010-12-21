class CreateDevicesByStatus < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
		create type device_by_status AS (
		    user_id integer,
		    first_name text,
		    last_name text,		    
		    device_id integer,
		    serial text
	  	);
	  	
		CREATE OR REPLACE FUNCTION devices_by_status(text)
		RETURNS setof device_by_status
		AS
		$$
      select users.id as user_id, profiles.first_name, profiles.last_name, devices_users.device_id, devices.serial_number from users
      left outer join devices_users on users.id = devices_users.user_id, devices, profiles
      where users.id = profiles.user_id
      and devices.id = devices_users.device_id 
      and users.status = $1
      order by users.id asc;     
		$$ 
		LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
