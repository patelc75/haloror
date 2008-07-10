
class BundleController < RestfulAuthController
  
  @@bundled_models = [Vital, StrapRemoved, StrapFastened, Step, SkinTemp, Fall, Panic, Battery, BatteryChargeComplete, BatteryCritical, BatteryPlugged, BatteryUnplugged]
  def create
    bundle = params[:bundle]
    data = {}
    
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
  end
end
