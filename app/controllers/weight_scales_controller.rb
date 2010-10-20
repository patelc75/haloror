class WeightScalesController < RestfulAuthController
  include UtilityHelper
  layout 'application' # render application layout for all actions here

  def index
    @seniors = current_user.is_caregiver_of_what.compact
    @senior = User.find_by_id( params[:id])
    @weight_scales = WeightScale.all( :conditions => { :user_id => params[:id] }, :order => "timestamp DESC").paginate( :page => params[:page], :per_page => 10)
  end
end
