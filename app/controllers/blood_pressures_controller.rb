class BloodPressuresController < RestfulAuthController
  include UtilityHelper
  
  def index
  	@blood_pressure = BloodPressure.paginate (:all,:page => params[:page])
  	render :layout => 'application'
  end
  
end
