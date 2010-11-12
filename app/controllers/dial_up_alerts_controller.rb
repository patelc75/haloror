class DialUpAlertsController < RestfulAuthController
layout 'application'
  def index
  	conditions = "1=1"
	conditions += " and device_id = #{params[:device_id]}" if params[:device_id] and params[:device_id] != ""
  	@dial_up_alerts = DialUpAlert.paginate :page => params[:page],:conditions => conditions,:order => 'timestamp asc',:per_page => 50
  end

  def create
    DialUpAlert.create( params[:dial_up_alert] )
    # @dial_up_alert = DialUpAlert.new(params[:dial_up_alert])
    # @dial_up_alert.save
  	render :nothing => true
  end

end
