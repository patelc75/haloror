class SandboxController < ApplicationController
  #layout "application", :except => "chart"

  def helloworld
  end

  def summary
    @avgHeartRate = Heartrate.average('heartRate');
    @maxHeartRate = Heartrate.maximum('heartRate');
    @minHeartRate = Heartrate.minimum('heartRate');
    @currentHeartRate = Heartrate.find(:first, :order => 'timeStamp')
  end
	
  def report
    @heartrates = Heartrate.find(:all)
  end
	
  def line_chart_discrete
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate" ) #write up this line in the blog
    
    heartrates = Heartrate.find(:all , :limit => 10)     # get information from the database    
    graph.add(:axis_category_text, heartrates.map {|a| a.timeStamp  } )      
    # create an array of labels by calling the name method on each animal
    graph.add(:series, "Discrete Heartrate", heartrates.map {|a| a.heartRate} ) 
    #    graph.add(:user_data, :chart_type, "discrete" ) 
    render :xml => graph.to_s
  end  
  
  def line_chart_continuous
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate2" ) #write up this line in the blog
    
    heartrates = Heartrate.find(:all , :limit => 20)     # get information from the database    
    graph.add(:axis_category_text, heartrates.map {|a| a.timeStamp  } )      
    # create an array of labels by calling the name method on each animal
    graph.add(:series, "Continuous Heartrate", heartrates.map {|a| a.heartRate} ) 
    #    graph.add(:user_data, :chart_type, "continuous" ) 
    render :xml => graph.to_s
  end  

  def current
    @recentHeartRate = Heartrate.find(:first, :order => 'id DESC')
    @currentHeartRate = @recentHeartRate.heartRate
  end
end