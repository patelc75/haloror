class WeightScalesController < RestfulAuthController
	include UtilityHelper

  def index
  	#@weight_scales = WeightScale.paginate (:all,:page => params[:page])
  	@weight_scales = WeightScale.find(:all,:conditions => ["user_id = ? ",params[:id]], :order => "timestamp DESC")
  	render :layout => 'application'
  end

end
