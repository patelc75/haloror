# FIXME: this will fail for sure. bundle_processors table does not exist
# WARNING: Need to discuss business logic here, or, get structure of the table
class BundleProcessor # < ActiveRecord::Base
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, 
                      SkinTemp, Battery, BatteryChargeComplete, 
                      BatteryCritical, BatteryPlugged, BatteryUnplugged, 
                      Fall, Panic, WeightScale, BloodPressure, 
                      HaloDebugMsg, OscopeMsg, OscopeStopMsg, 
                      OscopeStartMsg, GwAlarmButton, DialUpStatus]

  # #override new so it will accept parse through custom or multiple xml nodes in the model  
  # def self.new(xml_hash=nil)
  #   if(!xml_hash.nil?)
  #     self.process_xml_hash(xml_hash)
  #     return nil
  #     else
  #       super
  #   end
  # end

  # #initialize will need to be overriden since new() was overriden
  # def self.initialize(xml_hash=nil)
  #   if(xml_hash.nil?)
  #     super
  #   else
  #     self.new(xml_hash)
  #   end
  # end

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
              #
              # model specific additional parsing. check model class for more details.
              # keep this here. do not remove.
              obj.parse_for_xml_hash if obj.respond_to?(:parse_for_xml_hash)
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