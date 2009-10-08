class BloodPressuresController < RestfulAuthController
  include UtilityHelper
  
  def index
  	#@blood_pressure = BloodPressure.paginate (:all,:page => params[:page], :order => "timestamp DESC")
  	@blood_pressure = BloodPressure.find_all_by_user_id(params[:id], :order => "timestamp DESC")
  	render :layout => 'application'
  end
  
end
