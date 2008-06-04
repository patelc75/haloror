class RecreateTriggers < ActiveRecord::Migration
  def self.up
    begin
      execute "drop trigger device_latest_queries_trigger on mgmt_queries"
    rescue Exception
    end
    ddl = <<-eos
       create trigger device_latest_queries_trigger after insert on mgmt_queries
       for each row execute procedure device_latest_queries_trigger_function();
       eos
    execute ddl
    begin
      execute "drop trigger latest_vitals_trigger on vitals"
    rescue Exception
    end
    ddl2 = <<-eos
       create trigger latest_vitals_trigger after insert on vitals
       for each row execute procedure latest_vitals_trigger_function();
        eos
    execute ddl2
  end

  def self.down
    
    begin
      execute "drop trigger latest_vitals_trigger on vitals"
    rescue Exception
    end
    
    begin
      execute "drop trigger device_latest_queries_trigger on mgmt_queries"
    rescue Exception
    end
  end
end
