
class BundleController < RestfulAuthController
  
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, SkinTemp, Battery, BatteryChargeComplete, BatteryCritical, BatteryPlugged, BatteryUnplugged, Fall, Panic]
  def create
    bundle = params[:bundle]    
    begin
      @@bundled_models[0].transaction do
        @@bundled_models.each do |model|
          value = bundle[model.node_name]
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
      respond_to do |format|
        format.xml { head :ok } 
      end
    rescue
      RAILS_DEFAULT_LOGGER('ERROR in BundleController')
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
    end
  end
end

