class AlertBundleController < RestfulAuthController
  include UtilityHelper

  def create
    alert_bundle = params[:alert_bundle]
    begin
      BundleProcessor.process(alert_bundle)
      respond_to do |format|
        format.xml { head :ok } 
      end
    rescue RuntimeError => e
      RAILS_DEFAULT_LOGGER.warn("ERROR in BundleController:  #{e}")
      respond_to do |format|
        format.xml { head :internal_server_error }
      end
    end
  end
end

