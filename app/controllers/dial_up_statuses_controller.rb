class DialUpStatusesController < RestfulAuthController
layout 'application'
session :on,:except => :create
def index
	conditions = "1=1"
	conditions += " and device_id = #{params[:device_id]}" if params[:device_id] and params[:device_id] != ""
	conditions += " and dialup_type = '#{params[:dialup_type]}'" if params[:dialup_type] && params[:dialup_type] != 'Select Type'
    @dial_up_statuses = DialUpStatus.paginate :page => params[:page],:conditions => conditions,:order => 'created_at desc',:per_page => 50
end

def last_successful
	if params[:device_id] and params[:device_id] != ""
      @dial_up_last_successfuls = DialUpLastSuccessful.paginate :page => params[:page],:conditions => ["device_id = ?",params[:device_id]],:order   => 'created_at desc',:per_page => 20
	else
	  @dial_up_last_successfuls = DialUpLastSuccessful.paginate :page => params[:page],:order   => 'created_at desc',:per_page => 20
    end
end

def create
	request = params[:dial_up_status]
	DialUpStatus.process_xml_hash(request)
	render :nothing => true
end

end
