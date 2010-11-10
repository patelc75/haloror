class WeightScalesController < RestfulAuthController
  include UtilityHelper
  layout 'application' # render application layout for all actions here

  def index
    _id = params[:id]
    _options = ( _id.blank? ? {} : { :user_id => _id })
    @seniors = current_user.is_caregiver_of_what.compact # For user drop down on form
    @senior = ( _id.blank? ? @seniors.first : User.find( _id) )
    @weight_scales = WeightScale.all( :conditions => _options, :order => "timestamp DESC").paginate( :page => params[:page], :per_page => 10)
  end
end
