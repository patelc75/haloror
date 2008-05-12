require 'ziya'
require 'active_support'
require "drb"

class ChartController < ApplicationController
  include Ziya
  
  layout "application"
  
  def flex
    
  end
  
  def index
    unless logged_in?
      redirect_to '/login'
    else
      @user = which_user?
           
      @battery = Battery.find(:first,:conditions => "user_id = '#{@user.id}'",:order => "timestamp DESC")
      if @battery
        @gauge_width = 50 * (@battery.percentage/100.0)
      else
        @gauge_width = 0
      end
    
      @events = Event.find(:all, :limit => 10, :order => "id desc",:conditions => "user_id = '#{@user.id}'")
      
      if(@user.profile.time_zone)
        @tzs = @user.profile.tz
      else
        @tzs = TZInfo::Timezone.get('America/Chicago') 
      end
      
      @temp = SkinTemp.find(:first,:conditions => "user_id = '#{@user.id}'",:order => "timestamp DESC")
      #@temp = SkinTemp.find(:first, :order => 'id desc')
     
      @vital = Vital.find(:first,:conditions => "user_id = '#{@user.id}'",:order => "timestamp DESC")
    end
  end
  
  def gen_activity_pie
    g = Gruff::Pie.new("95x95")
    g.theme = {
      :colors => %w(#51ade0 #cae947 #7d939f #a6babc #666648),
      :marker_color => 'blue',
      :background_colors => %w(#f2f2f2 #f2f2f2)
    }
    g.font_color = '#f2f2f2'
    g.hide_legend = 1
    g.hide_line_markers = 1
    g.hide_line_numbers = 1
    g.hide_title

    g.data("Running", [45])
    g.data("Walking", [15])
    g.data("Standing", [10])
    g.data("Sleeping", [15])
    g.data("Sitting", [15])

    send_data(g.to_blob, 
      :disposition => 'inline', 
      :type => 'image/png', 
      :filename => "activity.png")
  end

  def view
    @user = which_user?
    
    if params[:type] != false
      cookies[:chart_type] = params[:type]
    end
    
    render(:layout => false , :partial => 'chart')
  end
  
  
  def line_chart
    #start_background_task
    @user = which_user?
    graph  = Ziya::Charts::Line.new( nil, nil, "line_chart" )  #points to line_chart.yml

    #graph.add :axis_category_text, @categories
    
    if cookies[:heartrate] == "false"
      @series_data = {}
      @series_labels = {}
    elsif
      gen_data_sets(Vital, 'heartrate', @user)
    end
    
    graph.add(:series, "Heartrate", @series_data, @series_labels)
	
    if cookies[:skin_temp] == "false"
      @series_data = {}
      @series_labels = {}
    elsif
      gen_data_sets(SkinTemp, 'skin_temp', @user)
    end
	
    # logger.debug{ "logger: @series_data =#{@series_data} \n" }    
    # logger.debug{ "logger: @series_labels =#{@series_labels} \n" }    

    graph.add(:series, "Skin Temperature", @series_data, @series_labels)
    
    render :xml => graph.to_xml
  end
  
  
  def activity_chart
    @user = which_user?
    graph  = Ziya::Charts::Column.new( nil, nil, "activity_chart" )  #points to chart_live.yml
    
    #gen_activity_data_sets
    #graph.add :axis_category_text, @activity_categories
    #graph.add :series, "Activity", @activity_series
	
    gen_data_sets(Vital, 'activity', @user)
    graph.add(:series, "Activity", @series_data, @series_labels)
    graph.add(:axis_category_text, @categories)
    
    render :xml => graph.to_xml
  end
  
  
  def refresh_data
    @user = User.find(cookies[:chart_user])
    
    if cookies[:skin_temp] == "false"
      @series_data = {}
      @series_labels = {}
    elsif
      gen_data_sets(SkinTemp, 'skin_temp', @user)
    end

    @skintemp_series = @series_data
    @skintemp_labels = @series_labels	
	
	
    if cookies[:heartrate] == "false"
      @series_data = {}
      @series_labels = {}
    elsif
      gen_data_sets(Vital, 'heartrate', @user) 
    end

    @heartrate_series = @series_data
    @heartrate_labels = @series_labels

    #render a special view which as XML file 
    render :template => 'chart/refresh_data.xml.builder', :layout => false
  end
  
  def refresh_activity_data
    @user = User.find(cookies[:chart_user])
    
    gen_data_sets(Vital, :activity, @user)
    @activity_series = @series_data
    #render a special view which as XML file 
    render :template => 'chart/refresh_activity_data.xml.builder', :layout => false
  end
  
  
  def line_chart_discrete
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate_discrete" ) #write up this line in the blog
    
    #    ending_time_stamp = Heartrate.find(:first, :order => 'timestamp DESC')
    #    beginning_time_stamp = Heartrate.find(:first, :order => 'timestamp ASC')
    #    start = beginning_time_stamp.timestamp
    #    ending = ending_time_stamp.timestamp;
    #average_data(10, beginning_time_stamp.timestamp, ending_time_stamp.timestamp )
    logger.error("line_chart_discrete::params[:start]= #{params[:start_time]}")
    logger.error("line_chart_discrete::params[:finish]= #{params[:finish_time]}")
    average_data(10, Time.parse(params[:start_time]), Time.parse(params[:finish_time])) #results stored in @labels_array & @averages_array
    
    graph.add(:axis_category_text, @labels_array)    
    graph.add(:series, "Discrete Heartrate", @averages_array )
    
    # graph.add(:user_data, :chart_type, "discrete" ) 
    render :xml => graph.to_s
  end  
  
  def line_chart_continuous
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate_continuous" )
    
    heartrates = Heartrate.find(:all , :limit => 20)     # get information from the database    
    graph.add(:axis_category_text, heartrates.map {|a| a.timeStamp  } )      
    # create an array of labels
    graph.add(:series, "Continuous Heartrate", heartrates.map {|a| a.heartRate} ) 
    # graph.add(:user_data, :chart_type, "continuous" ) 
    render :xml => graph.to_s
  end 

  def line_chart_hardcoded
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate_discrete" )
    
    heartrates = Heartrate.find(:all , :limit => 10)     # get information from the database    
    graph.add(:axis_category_text, ["8:32:15AM", "8:32:30AM", "8:32:45AM", "8:33:00AM","8:33:15AM", "8:33:30AM", "8:33:45AM", "8:34:00AM", "8:34:15AM", "8:34:30AM"] )      
    # create an array of labels by calling the name method on each animal
    graph.add(:series, "Discrete Heartrate", [72, 74, 73, 74, 72, 71,74, 72, 71, 70] ) 
    # graph.add(:user_data, :chart_type, "discrete" ) 
    render :xml => graph.to_s
  end  

  
  def heartrate_post
    heartrate = Heartrate.new(:user_id => 817, :timestamp => Time.now, :heartrate => rand(5)+70)
    heartrate.save
    render :nothing => true
  end
  
  def activity_post
    activity = Activity.new(:user_id => 817, :timestamp => Time.now, :activity => rand(10000)+9000)
    activity.save
    render :nothing => true
  end
  
  def update_overlay
    cookies[:heartrate] = params[:heartrate]
    cookies[:skin_temp] = params[:skin_temp]
    
    render :nothing => true
  end


  def round_to(num, x)
    (num * 10**x).round.to_f / 10**x
  end

  def gen_data_sets(model, column, user)
    #get the latest 10 records (ordered by timestamp) from Heartrate table
    end_time = Time.now
    #logger.debug{ "logger: current_user_id =#{current_user.id} \n" }    
	
    if cookies[:chart_type] == 'live' || !cookies[:chart_type]
      @series_data, @categories = model.latest_data(10, user.id, column)
    elsif
      if cookies[:chart_type] == 'last_half_hour'
        start_time = end_time - 30 * 60
      elsif cookies[:chart_type] == 'last_hour'
        start_time = end_time - 60 * 60
      elsif cookies[:chart_type] == 'last_six_hours'
        start_time = end_time - 6 * 60 * 60
      elsif cookies[:chart_type] == 'all_day'
        start_time = end_time - 24 * 60 * 60
      end
	  
      @series_data, @categories = model.average_data(10, start_time, end_time, current_user.id, column, nil)
    end
	
    #average_data(10, start_time, end_time) 
    @series_labels = @series_data  
    
    # random data with fixed arbitrary timestamps
    #    @categories = %w{ 8:32:15AM 8:32:30AM 8:32:45AM 8:33:00AM 8:33:15AM 8:33:30AM 8:33:45AM 8:34:00AM 8:34:15AM 8:34:30AM}
    #    @series_b    = [ rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70 ]      
  end
  
  def tabbed
    logger.info "test"
    render :layout => false
  end
  
  def error  
      raise RuntimeError, "Generating an error"  
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
