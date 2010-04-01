# FIXME: this will fail for sure. bundle_processors table does not exist
# WARNING: Need to discuss business logic here, or, get structure of the table
class BundleProcessor # < ActiveRecord::Base
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, 
                      SkinTemp, Battery, BatteryChargeComplete, 
                      BatteryCritical, BatteryPlugged, BatteryUnplugged, 
                      Fall, Panic, WeightScale, BloodPressure, 
                      HaloDebugMsg, OscopeMsg, OscopeStopMsg, 
                      OscopeStartMsg, GwAlarmButton, DialUpStatus, DialUpLastSuccessful]

  # process the bundle
  #
  def self.process(bundle)
    bundle = bundle["oscope_msgs"] if bundle.has_key?("oscope_msgs") # https://redmine.corp.halomonitor.com/issues/2724
    RAILS_DEFAULT_LOGGER.warn("Entering BundleProcessor.self_process")
    begin
      @@bundled_models[0].transaction do
        @@bundled_models.each do |model|
          #
          # for dial_up_status, we want the entire bundle, not extracted hash
          value = ((model.to_s.underscore == "dial_up_status") && bundle.has_key?("num_failures")) ? bundle : bundle[model.to_s.underscore]
          
          unless value.blank?
            value = (value.class == Array ? value : [value])
            value.each do |v|
              obj = model.new(v)
              #
              # model specific additional parsing. check model class for more details.
              # keep this here. do not remove.
              # not required anymore => obj.parse_for_xml_hash if obj.respond_to?(:parse_for_xml_hash)
              #
              # CHANGED: As of 2010-03-12, we do not need this special case. The logic is inside model now.
              #
              obj.save! unless obj.blank? rescue nil
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