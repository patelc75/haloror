# FIXME: this will fail for sure. bundle_processors table does not exist
# WARNING: Need to discuss business logic here, or, get structure of the table
require "lib/dial_up_status_module"

class BundleProcessor # < ActiveRecord::Base
  extend DialUpStatusModule
  
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, 
                      SkinTemp, Battery, BatteryChargeComplete, 
                      BatteryCritical, BatteryPlugged, BatteryUnplugged, 
                      Fall, Panic, WeightScale, BloodPressure, 
                      HaloDebugMsg, OscopeStartMsg, OscopeStopMsg, OscopeMsg,
                      GwAlarmButton, DialUpStatus, DialUpLastSuccessful, DialUpAlert]

  # process the bundle
  #
  def self.process(bundle)
    bundle = bundle["oscope_msgs"] if bundle.has_key?("oscope_msgs") # https://redmine.corp.halomonitor.com/issues/2724
    RAILS_DEFAULT_LOGGER.warn("Entering BundleProcessor.self_process")
    begin
      @@bundled_models[0].transaction do
        @@bundled_models.each do |_model|
          #
          # for dial_up_status, we want the entire bundle, not extracted hash
          # https://redmine.corp.halomonitor.com/issues/2742
          value = ( ((_model.to_s.underscore == "dial_up_status") && bundle.has_key?("num_failures")) || \
                    ((_model.to_s.underscore == "oscope_start_msg") && bundle.has_key?("capture_reason")) \
                  ) ? bundle : bundle[_model.to_s.underscore]
          
          unless value.blank?
            value = (value.class == Array ? value : [value])
            value.each do |v|

              # get the hashes separate for each row of AR
              # WARNING: Not tested
              if v.keys.include?( "alt_status") # composite hash received from device
                # we need this conditional clause here
                #   dial_up_status had issues in posting correct data otherwise
                #   https://redmine.corp.halomonitor.com/issues/3255
                save_dial_up_status_hash( v)
              else
                obj = _model.new(v)
              end

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