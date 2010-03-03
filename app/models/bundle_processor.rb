class BundleProcessor
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, 
                      SkinTemp, Battery, BatteryChargeComplete, 
                      BatteryCritical, BatteryPlugged, BatteryUnplugged, 
                      Fall, Panic, WeightScale, BloodPressure, 
                      HaloDebugMsg, OscopeMsg, OscopeStopMsg, 
                      OscopeStartMsg, GwAlarmButton, DialUpStatus]

  # process the bundle
  #
  def self.process(bundle)
    RAILS_DEFAULT_LOGGER.warn("Entering BundleProcessor.self_process")
    begin
      @@bundled_models[0].transaction do
        @@bundled_models.each do |model|
          value = bundle[model.to_s.underscore]

          unless value.blank?
            value = (value.class == Array ? value : [value])
            value.each do |v|
              obj = model.new(v)
              (obj.save! if obj.valid?) unless obj.blank?
            end

          end
        end
      end
      #
      # FIXME: avoid exceptions. re-factor here
    rescue RuntimeError => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in BundleProcessor:  #{e}")
    end
  end
end