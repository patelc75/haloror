require 'healthvault'
require 'chronic'
class HealthvaultController < ApplicationController
  include HealthVault
  before_filter :authenticate_admin_halouser_caregiver_operator?
  layout "application"
  
  before_filter :setup_healthvault, :except => [:error]
  before_filter :setup_hv_user, :except => [:error, :shellreturn]
  def index
    
  end
  
  def get_vitals
    request = Request.create("GetThings", connection)
    request.header.record_id = session[:healthvault_record_id]
    request.info.add_group(WCData::Methods::GetThings::ThingRequestGroup.new)
    request.info.group[0].format = WCData::Methods::GetThings::ThingFormatSpec.new
    request.info.group[0].format.add_xml("")
    request.info.group[0].format.add_section("core")
    request.info.group[0].add_filter(WCData::Methods::GetThings::ThingFilterSpec.new)
    request.info.group[0].filter[0].add_type_id("b81eb4a6-6eac-4292-ae93-3872d6870994") # Heart rate
    # request.info.group[0].filter[0].add_type_id("40750a6a-89b2-455c-bd8d-b420a4cb500b") # Height 
    result = request.send
    
    @results = []
    result.info.group[0].thing.each do |thing|
      @results.push([thing.data_xml[0].when.to_s, thing.data_xml[0].value.to_s]) rescue [nil, "missing heart rate"]
    end
  end
  
  def send_vitals
    request = Request.create("PutThings", @hv_conn)
    request.header.record_id = session[:healthvault_record_id]

    hours = params[:hours].to_i
    if hours < 1
      hours = 1
    elsif hours > 24
      hours = 24
    end
    
    end_time = Chronic.parse(params[:end_time])
    
    
    # Vital.find(:first, :conditions => "user_id = 2")
    # ts = Vital.find(:first, :conditions => "user_id = 2").timestamp
    # vitals = Vital.average_data(12, ts, ts + 12.hour, 2, :heartrate, nil)
    # pairs = vitals[0].zip(vitals[1])
    
    
    vitals = Vital.average_data(hours, end_time - hours.hour, end_time, @user[:id], :heartrate, nil) # zip this up
    
    pairs = vitals[0].zip(vitals[1])
    
    pairs.each do |pair|
      vit = pair[0]
      ts = pair[1]
      heart_thing = WCData::Thing::Thing.guid_to_class("b81eb4a6-6eac-4292-ae93-3872d6870994").new
      heart_thing.when.date.y = ts.year
      heart_thing.when.date.m = ts.month
      heart_thing.when.date.d = ts.day
      heart_thing.when.time.h = ts.hour
      heart_thing.when.time.m = ts.min
      heart_thing.when.time.s = ts.sec
      heart_thing.value = vit

      thething = WCData::Thing::Thing.new

      thething.type_id = "b81eb4a6-6eac-4292-ae93-3872d6870994"
      thething.add_data_xml(HealthVault::WCData::Thing::DataXml.new)
      thething.data_xml[0].anything = height_thing
      request.info.add_thing(thething)
    end
    
    @request = request
    @result = request.send
  end
  
  def error
    render :text => "there was an error: #{flash[:error]}" and return
  end
  #http://haloror.local/healthvault/shellreturn/?target=AppAuthSuccess&actionqs=5&wctoken=ASAAAGqn95wyJApHq8YUaIVfeJMviBab%2bTeRDXp0fOG905Xy34q3ded0yqVqGXwQb%2f0WH%2b4%2bomWfyWBqkhJRVUQ7J%2fVbcPkoVCK2utvRefbEtPfN7UoVw3eDlzMRoOBogbtLViGwqfIkvPn8m3Xt4b2R9AKGbBRCnrMClSDGsr5knqTmZye8BA%3d%3d
  def shellreturn
    #raise request.query_parameters.inspect
    if (request.query_parameters["target"].downcase == "appauthsuccess")
      session[:wctoken] = request.query_parameters["wctoken"]
      session[:actionqs] = request.query_parameters["actionqs"]
      if @user[:id].to_i != session[:actionqs].to_i
        flash[:error] = "bad user id: #{@user[:id]} versus actionqs #{session[:actionqs]}"
      else
        @hv_conn.user_auth_token = session[:wctoken]
        flash[:error] = "things worked!"
      end
      redirect_to :controller => 'healthvault', :action => 'error'
    else
      flash[:error] = "Got a target shell return of #{request.query_parameters['target']}"
      redirect_to 'error' and return
    end
  end
  
  private
  
  def setup_healthvault
    # Must be logged in
    unless logged_in?
      redirect_to '/login'
    else
      @user = which_user?
    end
    
    # Try to get the existing app and connection from the session
    if !session[:healthvault_app].blank? && !session[:healthvault_conn].blank?
      @hv_app = session[:healthvault_app]
      @hv_conn = session[:healthvault_conn]
    else
    # otherwise, connect to healthvault, authenticate the app, and store the result in the session
      @hv_app = Application.default
      @hv_conn = @hv_app.create_connection
      @hv_conn.authenticate
      session[:healthvault_app] = @hv_app
      session[:healthvault_conn] = @hv_conn
    end
    
    # error checking
    if (!@hv_conn.authenticated?(:app))
      flash[:error] = "Could not authenticate application with healthvault"
      redirect_to(:action => "error", :status => 302) and return
    end
  end
  
  def setup_hv_user
    # If the user isn't authenticated...
    if (!@hv_conn.authenticated?(:user))
      config = Configuration.instance
      auth_url = "#{config.shell_url}/redirect.aspx?target=AUTH&targetqs=?actionqs=#{@user[:id]}%26appid=#{config.app_id}%26redirect=#{url_for :controller => 'healthvault', :action => 'shellreturn'}"
      redirect_to(auth_url, :status => 302) and return
    end
    
    if session[:healthvault_record_id].blank? || session[:healthvault_name].blank?

      request = Request.create("GetPersonInfo", @hv_conn)
      result = request.send

      hv_name = result.info.person_info.name
      record_id = result.info.person_info.selected_record_id
    
      session[:healthvault_record_id] = record_id
      session[:healthvault_name] = hv_name
    end
  end

  def which_user?
    if params[:id] && current_user.is_administrator?
      user = User.find(params[:id])
    else
      user = current_user
    end
    
    cookies[:chart_user] = user.id.to_s
    
    user
  end

end