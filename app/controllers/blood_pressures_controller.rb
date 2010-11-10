class BloodPressuresController < RestfulAuthController
  include UtilityHelper

  def index
    # 
    #  Wed Nov 10 03:03:40 IST 2010, ramonrails
    #   * allow to select user
    #   * paginate the list
    @seniors = current_user.is_caregiver_of_what.compact # For user drop down on form
    @senior = User.find_by_id( params[:id])
    @blood_pressures = BloodPressure.all( :conditions => { :user_id => params[:id] }, :order => "timestamp DESC").paginate( :page => params[:page], :per_page => 10)
    # #@blood_pressure = BloodPressure.paginate (:all,:page => params[:page], :order => "timestamp DESC")
    # @blood_pressure = BloodPressure.find(:all,:conditions => ["user_id = ? ",params[:id]], :order => "timestamp DESC")
    render :layout => 'application'
  end
end
