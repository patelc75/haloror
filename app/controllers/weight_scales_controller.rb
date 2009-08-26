class WeightScalesController < RestfulAuthController
	include UtilityHelper

  def index
  	@weight_scales = WeightScale.paginate (:all,:page => params[:page])
  	render :layout => 'application'
  end

end
