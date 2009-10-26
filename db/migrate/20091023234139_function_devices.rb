class FunctionDevices < ActiveRecord::Migration
  def self.up
	ddl = <<-eos
		create type device_info AS (
		    revision   character varying(255),
		    type  character varying(255),
		    model  character varying(255)
	  	);

		CREATE OR REPLACE FUNCTION devices()
		RETURNS setof device_info
		AS
		$$
			select device_revisions.revision as revision, device_types.device_type as type, device_models.part_number as model from device_revisions,device_types,device_models where device_revisions.device_model_id = device_models.id and device_models.device_type_id = device_types.id;
		$$ 
		LANGUAGE 'sql' STABLE;
    eos

    execute ddl
  end

  def self.down
  end
end
