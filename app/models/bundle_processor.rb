class BundleProcessor
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, 
                      SkinTemp, Battery, BatteryChargeComplete, 
                      BatteryCritical, BatteryPlugged, BatteryUnplugged, 
                      Fall, Panic, WeightScale, BloodPressure, 
                      HaloDebugMsg, OscopeMsg, OscopeStopMsg, OscopeStartMsg]
  def self.process(bundle)
    RAILS_DEFAULT_LOGGER.warn("Entering BundleProcessor.self_process")
    begin
      @@bundled_models[0].transaction do
        @@bundled_models.each do |model|
          value = bundle[model.to_s.underscore]
          if !value.blank?
            if value.class == Array
              value.each do |v|
                model.new(v).save!
              end
            else
              model.new(value).save!
            end
          end
        end
      end
    rescue RuntimeError => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in BundleProcessor:  #{e}")
    end
  end
end