class DialUpStatusesController < RestfulAuthController

def index
	@dial_up_statuses = DialUpStatus.find(:all)
	@dial_up_last_successfuls = DialUpLastSuccessful.find(:all)
	render :layout => 'application'
end

def create
	request = params[:dial_up_status]
	
	#Primary Number
	DialUpStatus.create(:phone_number => request[:number],:status => request[:status],:device_id => request[:device_id],:configured => request[:configured],:num_failures => request[:num_failures],:consecutive_fails => request[:consecutive_fails],:ever_connected => request[:ever_connected],:dialup_type => 'Local')
	
	#Local Alternative Number
	DialUpStatus.create(:phone_number => request[:alt_number],:status => request[:alt_status],:device_id => request[:device_id],:configured => request[:alt_configured],:num_failures => request[:alt_num_failures],:consecutive_fails => request[:alt_consecutive_fails],:ever_connected => request[:alt_ever_connected],:dialup_type => 'Local')
	
	#Global Primary Number
	DialUpStatus.create(:phone_number => request[:global_prim_number],
	:status => request[:global_prim_status],
	:device_id => request[:device_id],
	:configured => request[:global_prim_configured],
	:num_failures => request[:global_prim_num_failures],
	:consecutive_fails => request[:global_prim_consecutive_fails],
	:ever_connected => request[:global_prim_ever_connected],
	:dialup_type => 'Global')
	
	#Global Alternative Number
	DialUpStatus.create(:phone_number => request[:global_alt_number],:status => request[:global_alt_status],:device_id => request[:device_id],:configured => request[:global_alt_configured],:num_failures => request[:global_alt_num_failures],:consecutive_fails => request[:global_alt_consecutive_fails],:ever_connected => request[:global_alt_ever_connected],:dialup_type => 'Global')
	
	#Last Successful Number
	DialUpLastSuccessful.create(:device_id => request[:device_id],:last_successful_number => request[:last_successful_number],:last_successful_username => request[:last_successful_username],:last_successful_password => request[:last_successful_password])
	
	render :nothing => true
end

end
