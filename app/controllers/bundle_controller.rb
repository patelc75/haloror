class BundleController < RestfulAuthController
  include UtilityHelper

  def create
    bundle = params[:bundle]
    begin
      BundleProcessor.process(bundle) # https://redmine.corp.halomonitor.com/issues/2724
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

