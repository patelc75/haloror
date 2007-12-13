require 'ziya'
require 'active_support'
require "drb"

class ChartController < ApplicationController
  include Ziya
  
  def index
    @battery = Battery.find(:first, :order=>"id DESC")
    @gauge_width = 50 * (@battery.percentage/100.0)
    
    #render(
    #:partial => 'chart_live', 
    #:layout => true
    #)
    
    cookies[:heartrate] = "true"
    #cookies[:activity] = "true"
    cookies[:skin_temp] = "true"
  end
  
  def gen_activity_pie
    g = Gruff::Pie.new("95x95")
    g.theme = {
       :colors => %w(#51ade0 #cae947 #7d939f #a6babc #666648),
       :marker_color => 'blue',
       :background_colors => %w(#f2f2f2 #f2f2f2)
     }
     
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

  def chart_live
    render(
    :partial => 'chart_live', 
    :layout => false
    )
  end
  
  def heartrate_last_half_hour
    render(
    :partial => 'heartrate_discrete', 
    :locals => {
      :start =>'2007-08-30 18:14:37-04',
      :finish => '2007-08-30 18:44:37-04',          
    },
    :layout => false
    )
  end 
  
  def heartrate_last_hour
    render(
    :partial => 'heartrate_discrete', 
    :locals => {
      :start => '2007-08-30 17:44:37-04',          
      :finish => '2007-08-30 18:44:37-04',                
    },
    :layout => false
    )
  end 

  def heartrate_last_six_hours
    render(
    :partial => 'heartrate_discrete', 
    :locals => {
      :start => '2007-08-30 12:44:37-04',          
      :finish => '2007-08-30 18:44:37-04',                
    },
    :layout => false
    )
  end 

  def heartrate_all_day
    render(
    :partial => 'heartrate_discrete', 
    :locals => {
      :start =>'2007-08-30 06:00:00-04',
      :finish => '2007-08-30 18:44:37-04',
    },
    :layout => false
    )
  end 
  
  def line_chart_live
    #start_background_task
    
    graph  = Ziya::Charts::Line.new( nil, nil, "chart_live" )  #points to chart_live.yml
    
    # heartrate
	  gen_live_heartrate_data_sets
    graph.add :axis_category_text, @categories
    
    graph.add :series, "Discrete Heartrate", @heartrate_series 
    
    # activity
    #gen_live_activity_data_sets
    #graph.add :series, "Activity", @activity_series
    
    # skin temp
    gen_live_skintemp_data_sets
    graph.add :series, "Skin Temperature", @skintemp_series
    
    render :xml => graph.to_xml
  end
  
  def activity_chart_live
    #start_background_task
    
    graph  = Ziya::Charts::Column.new( nil, nil, "activity_chart_live" )  #points to chart_live.yml
    
    # activity
    gen_live_activity_data_sets
    graph.add :axis_category_text, @activity_categories
    graph.add :series, "Activity", @activity_series
    
    render :xml => graph.to_xml
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

  
  def average_data(num_points, start_time, end_time)
    @averages_array = Array.new  #results of averaging from database
    @labels_array = Array.new
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on
    
    while current_point < num_points
      condition = "timestamp > '#{current_time}' AND timestamp < '#{current_time + interval}'"
      average = Heartrate.average(:heartrate, :conditions => condition)
      current_time = current_time + interval
      current_point = current_point + 1
      @averages_array << round_to(average, 1)
      @labels_array << current_time.strftime("%H:%M:%S")
    end 
    
    #for debugging
    @averages_array.each_with_index() do |x, i| 
      puts x, @labels_array[i]
    end
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
    #cookies[:activity] = params[:activity]
    cookies[:skin_temp] = params[:skin_temp]
    
    render :layout => false
  end
  
  def refresh_data
    gen_live_heartrate_data_sets
    #gen_live_activity_data_sets
    gen_live_skintemp_data_sets

    #render a special view which as XML file 
    render :template => 'chart/refresh_data', :layout => false
  end
  
  def refresh_activity_data
    gen_live_activity_data_sets

    #render a special view which as XML file 
    render :template => 'chart/refresh_activity_data', :layout => false
  end

  def round_to(num, x)
    (num * 10**x).round.to_f / 10**x
  end


  def gen_live_heartrate_data_sets    
    #get the latest 10 records (ordered by timestamp) from Heartrate table 
    heartrate = Heartrate.find(:all , :limit => 10, :order => "timestamp DESC").reverse 
    
    @categories =  heartrate.map {|a| a.timestamp.strftime("%H:%M:%S") }
    
    if cookies[:heartrate] == "true"
      @heartrate_series  = heartrate.map {|a| a.heartrate }
    else
      @heartrate_series = {}
    end
    
    # random data with fixed arbitrary timestamps
    #    @categories = %w{ 8:32:15AM 8:32:30AM 8:32:45AM 8:33:00AM 8:33:15AM 8:33:30AM 8:33:45AM 8:34:00AM 8:34:15AM 8:34:30AM}
    #    @series_b    = [ rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70, rand(4)+70 ]    
  end

  def gen_live_activity_data_sets    
    activity = Activity.find(:all , :limit => 10, :order => "timestamp DESC").reverse 
    
    @activity_categories =  activity.map {|a| a.timestamp.strftime("%H:%M:%S") }
    
    #if cookies[:activity] == "true"
      @activity_series  = activity.map {|a| a.activity }        #put in terms of heartrate
    #else
      #@activity_series = {}
    #end
  end
  
  def gen_live_skintemp_data_sets    
    skin_temp = SkinTemp.find(:all , :limit => 10, :order => "timestamp DESC").reverse 
    
    if cookies[:skin_temp] == "true"
      @skintemp_series  = skin_temp.map {|a| (a.skin_temp - 68)/0.2 }        #put in terms of heartrate
    else
      @skintemp_series = {}
    end
  end
  
  def start_background_task
    session[:job_key]= MiddleMan.new_worker(:class => :heartrate_worker,
    :args => "Arguments used to instantiate a new HeartratepostWorker object")
    
        session[:job_key] = worker
        MiddleMan.schedule_worker(
          :class => :heartrate_post_worker,
          :args => "some arg to do_work",
          :job_key => :simple_schedule,
          :trigger_args => {
            :start => Time.now,
            :end => Time.now + 10.minutes,
            :repeat_interval => 15.seconds
          }
        )
  end
  
  def tabbed
	logger.info "test"
	render :layout => false
  end
end