class WeightScalesController < RestfulAuthController
	include UtilityHelper

  def index
  	#@weight_scales = WeightScale.paginate (:all,:page => params[:page])
  	@weight_scales = WeightScale.find_all_by_user_id(params[:id], :order => "timestamp DESC")
  	render :layout => 'application'
  end

end
