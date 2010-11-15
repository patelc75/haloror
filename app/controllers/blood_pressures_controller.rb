class BloodPressuresController < RestfulAuthController
  include UtilityHelper
  layout 'application'

  def index
    # 
    #  Wed Nov 10 03:03:40 IST 2010, ramonrails
    #   * allow to select user
    #   * paginate the list
    _id = params[:id]
    _options = ( _id.blank? ? {} : { :user_id => _id })
    @seniors = current_user.is_caregiver_of_what.compact # For user drop down on form
    @senior = ( _id.blank? ? @seniors.first : User.find( _id) )
    @blood_pressures = BloodPressure.all( :conditions => _options, :order => "timestamp DESC").paginate( :page => params[:page], :per_page => 10)
  end
end
