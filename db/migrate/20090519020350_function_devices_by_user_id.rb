class FunctionDevicesByUserId < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
		create type device_by_user AS (
		    device_id   integer,
		    serial_number  character varying(255),
		    user_id integer, 
		    login character varying(255)
	  	);
	  	
		CREATE OR REPLACE FUNCTION devices_by_user_id(integer)
		RETURNS setof device_by_user
		AS
		$$
			select devices.id as device_id, devices.serial_number, users.id as user_id, users.login from devices, users, devices_users where devices_users.user_id=$1 and users.id = $1 and devices.id = devices_users.device_id;
		$$ 
		LANGUAGE 'sql' STABLE;
    eos
    
    execute ddl
  end

  def self.down
  end
end
