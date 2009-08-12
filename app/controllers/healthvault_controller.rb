require 'healthvault'
require 'chronic'
class HealthvaultController < ApplicationController
  include HealthVault
  before_filter :authenticate_admin_halouser_caregiver_operator?
  layout "application"
  
  before_filter :setup_healthvault, :except => [:index, :error, :logout, :privacy, :eula]
  before_filter :setup_hv_user, :except => [:index, :error, :shellreturn, :logout, :privacy, :eula]
  
  def index
    if !session[:healthvault_app].blank? && !session[:healthvault_conn].blank?
      @connected = true
      @hv_app = session[:healthvault_app]
      @hv_conn = session[:healthvault_conn]
      @hv_record_id = session[:healthvault_record_id]
      @hv_name = session[:healthvault_name]
    else
      @connected = false
    end
  end
  
  def logout
    unless logged_in?
      redirect_to '/login'
    else
      @user = which_user?
    end

    config = Configuration.instance
    auth_url = "#{config.shell_url}/redirect.aspx?target=APPSIGNOUT&targetqs=?actionqs=#{params[:action]}^#{@user[:id]}%26appid=#{config.app_id}%26redirect=#{url_for :controller => 'healthvault', :action => 'shellreturn'}"
    redirect_to(auth_url, :status => 302) and return
  end
  
  def login
    flash[:message] = "logged in"
    redirect_to :action => "index" and return
  end
  
  def privacy
  end
  
  def eula
  end
  
  def get_vitals
    request = Request.create("GetThings", @hv_conn)
    request.header.record_id = session[:healthvault_record_id]
    request.info.add_group(WCData::Methods::GetThings::ThingRequestGroup.new)
    request.info.group[0].format = WCData::Methods::GetThings::ThingFormatSpec.new
    request.info.group[0].format.add_xml("")
    request.info.group[0].format.add_section("core")
    request.info.group[0].add_filter(WCData::Methods::GetThings::ThingFilterSpec.new)
    request.info.group[0].filter[0].add_type_id("b81eb4a6-6eac-4292-ae93-3872d6870994") # Heart rate
    # request.info.group[0].filter[0].add_type_id("40750a6a-89b2-455c-bd8d-b420a4cb500b") # Height 
    
    @request_out = request
    result = request.send
    
    @result_out = result
    @results = []
    result.info.group[0].thing.each do |thing|
      datething = thing.data_xml[0].when
      datestr = "%s-%02s-%02s %02s:%02s:%02s" % [datething.date.y, datething.date.m, datething.date.d, datething.time.h, datething.time.m, datething.time.s]
      @results.push([datestr, thing.data_xml[0].value.to_s]) rescue [nil, "missing heart rate"]
    end
  end
  
  def send_vitals
    request = Request.create("PutThings", @hv_conn)
    request.header.record_id = session[:healthvault_record_id]

    @hours = params[:hours].to_i
    if @hours < 1
      @hours = 1
    elsif @hours > 24
      @hours = 24
    end
    
    #The format (eg. August 12, 2009 4:31 AM) returned from the calendar control is not supported by Chronic
    #See http://chronic.rubyforge.org/
    #@start_time = Chronic.parse(params[:start_time])
    #@start_time = Time.at((Chronic.parse(params[:start_time]).to_f / (1.hour)).floor * 1.hour)
    begin
      DateTime.parse(params[:start_time])
    rescue ArgumentError
      flash[:error] = "Invalid date or time entered."
      redirect_to :index and return
    end

    @start_time = Time.at((DateTime.parse(params[:start_time]).to_f / (1.hour)).floor * 1.hour)
    
    @end_time = @start_time + @hours.hour
    
    # Vital.find(:first, :conditions => "user_id = 2")
    # ts = Vital.find(:first, :conditions => "user_id = 2").timestamp
    # vitals = Vital.average_data(12, ts, ts + 12.hour, 2, :heartrate, nil)
    # pairs = vitals[0].zip(vitals[1])
    
    
    vitals = Vital.average_data(@hours, @start_time, @end_time, @user[:id], :heartrate, nil) # zip this up
    
    @pairs = vitals[0].zip(vitals[1])

    @pairs.each do |pair|
      vit = pair[0] < 0 ? 0 : pair[0]
      ts = pair[1]
      heart_thing = WCData::Thing::Thing.guid_to_class("b81eb4a6-6eac-4292-ae93-3872d6870994").new
      
      heart_thing.when.date.y = ts.year
      heart_thing.when.date.m = ts.month
      heart_thing.when.date.d = ts.day
      
      heart_thing.when.time = HealthVault::WCData::Dates::Time.new
      heart_thing.when.time.h = ts.hour
      heart_thing.when.time.m = ts.min
      heart_thing.when.time.s = ts.sec
      heart_thing.value = vit.round

      thething = WCData::Thing::Thing.new

      thething.type_id = "b81eb4a6-6eac-4292-ae93-3872d6870994"
      thething.add_data_xml(HealthVault::WCData::Thing::DataXml.new)
      thething.data_xml[0].anything = heart_thing
      request.info.add_thing(thething)
    end
    
    @request = request
    
    if params[:confirm]
      @result = request.send
    end
  end
  
  def error
    render :text => "there was an error: #{flash[:error]}" and return
  end
  #http://haloror.local/healthvault/shellreturn/?target=AppAuthSuccess&actionqs=5&wctoken=ASAAAGqn95wyJApHq8YUaIVfeJMviBab%2bTeRDXp0fOG905Xy34q3ded0yqVqGXwQb%2f0WH%2b4%2bomWfyWBqkhJRVUQ7J%2fVbcPkoVCK2utvRefbEtPfN7UoVw3eDlzMRoOBogbtLViGwqfIkvPn8m3Xt4b2R9AKGbBRCnrMClSDGsr5knqTmZye8BA%3d%3d
  def shellreturn
    #raise request.query_parameters.inspect
    case request.query_parameters["target"].downcase
    when "appauthsuccess"
      session[:wctoken] = request.query_parameters["wctoken"]
      session[:actionqs] = request.query_parameters["actionqs"]
      pair = session[:actionqs].split('^')
      session[:hv_user_id] = pair[1]
      return_action = pair[0]
      if @user[:id].to_i != session[:hv_user_id].to_i
        flash[:error] = "bad user id: #{@user[:id]} versus returned #{session[:hv_user_id]} (actionqs #{session[:actionqs]})"
      else
        @hv_conn.user_auth_token = session[:wctoken]
        setup_hv_user
        flash[:message] = "Got a good shell return, now we're logged in"
        redirect_to :action => return_action and return
      end
      redirect_to :controller => 'healthvault', :action => 'error'
    when "appauthinvalidrecord"
      session[:healthvault_record_id] = nil
      session[:healthvault_name] = nil
      flash[:message] = "Your selected HealthVault record seems to have been invalid."
      redirect_to 'index' and return
    when "appauthreject"
      flash[:error] = "You did not successfully log on to HealthVault."
      redirect_to 'index' and return
    when "help"
      redirect_to 'help' and return
    when "home"
      redirect_to 'index' and return
    when "privacy"
      redirect_to 'privacy' and return
    when "reconcilecanceled"
      flash[:message] = "Your CCR/CCD request was cancelled."
      redirect_to 'index' and return
    when "reconcilecomplete"
      flash[:message] = "Your CCR/CCD request completed successfully."
      redirect_to 'index' and return
    when "reconcilefailure"
      flash[:error] = "Your CCR/CCD request could not be completed."
      redirect_to 'index' and return
    when "selectedrecordchanged"
      session[:healthvault_record_id] = nil
      session[:healthvault_name] = nil
      flash[:message] = "Your selected HealthVault record has been changed."
      redirect_to 'index' and return
    when "serviceagreement"
      redirect_to 'eula' and return
    when "sharerecordfailed"
      flash[:error] = "Your record-sharing invitation could not be sent."
      redirect_to 'index' and return
    when "sharerecordsuccess"
      flash[:message] = "Your record-sharing invitation has been sent."
      redirect_to 'index' and return
    when "signout"
      session[:healthvault_app] = nil
      session[:healthvault_conn] = nil
      session[:healthvault_record_id] = nil
      session[:healthvault_name] = nil
      flash[:message] = "logged out"
      redirect_to :action => "index" and return
    end
    flash[:error] = "Got an unrecognized response from the HealthVault servers (#{request.query_parameters['target']})"
    redirect_to 'index' and return
  end
  
  private
  
  def setup_healthvault
    # Must be logged in
    unless logged_in?
      redirect_to '/login'
    else
      @user = which_user?
    end
    
    Configuration.instance.app_id = HV_APP_ID
    Configuration.instance.cert_file = HV_CERT_FILE
    Configuration.instance.cert_pass = HV_CERT_PASS
    Configuration.instance.shell_url = HV_SHELL_URL
    Configuration.instance.hv_url = HV_HV_URL
    
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
      auth_url = "#{config.shell_url}/redirect.aspx?target=AUTH&targetqs=?actionqs=#{params[:action]}^#{@user[:id]}%26appid=#{config.app_id}%26redirect=#{url_for :controller => 'healthvault', :action => 'shellreturn'}"
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