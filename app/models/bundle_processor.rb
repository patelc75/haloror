class BundleProcessor < ActiveRecord::Base
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, 
                      SkinTemp, Battery, BatteryChargeComplete, 
                      BatteryCritical, BatteryPlugged, BatteryUnplugged, 
                      Fall, Panic, WeightScale, BloodPressure, 
                      HaloDebugMsg, OscopeMsg, OscopeStopMsg, 
                      OscopeStartMsg, GwAlarmButton, DialUpStatus]

  #override new so it will accept parse through custom or multiple xml nodes in the model  
  def self.new(xml_hash=nil)
    if(!xml_hash.nil?)
  	  self.process_xml_hash(xml_hash)
  	  return nil
	  else
	    super
  	end
  end

  #initialize will need to be overriden since new() was overriden
  def self.initialize(xml_hash=nil)
    if(xml_hash.nil?)
      super
    else
      self.new(xml_hash)
    end
  end
                      
  def self.process(bundle)
    RAILS_DEFAULT_LOGGER.warn("Entering BundleProcessor.self_process")
    begin
      @@bundled_models[0].transaction do
        @@bundled_models.each do |model|
          value = bundle[model.to_s.underscore]
          if !value.blank?
            if value.class == Array
              value.each do |v|
                obj = model.new(v)
                if !obj.nil? #OscopeMsg.new does not return an object since it's not a simple object
                  obj.save!
                end
              end
            else
              obj = model.new(value)
              if !obj.nil? #OscopeMsg.new does not return an object since it's not a simple objectd
                obj.save!
              end
            end
          end
        end
      end
    rescue RuntimeError => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in BundleProcessor:  #{e}")
    end
  end
end