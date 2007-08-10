require 'ziya'

class ChartController < ApplicationController
  include Ziya
  
  def line
   
  end

  def line_chart_static
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate" ) #write up this line in the blog
    
    heartrates = Heartrate.find(:all , :limit => 10)     # get information from the database    
    graph.add(:axis_category_text, ["8:32:15AM", "8:32:30AM", "8:32:45AM", "8:33:00AM","8:33:15AM", "8:33:30AM", "8:33:45AM", "8:34:00AM", "8:34:15AM", "8:34:30AM"] )      
    # create an array of labels by calling the name method on each animal
    graph.add(:series, "Discrete Heartrate", [72, 74, 73, 74, 72, 71,74, 72, 71, 70] ) 
    # graph.add(:user_data, :chart_type, "discrete" ) 
    render :xml => graph.to_s
  end  
  
  def line_chart_discrete
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate" ) #write up this line in the blog
    
    heartrates = Heartrate.find(:all , :limit => 10)     # get information from the database    
    graph.add(:axis_category_text, heartrates.map {|a| a.timeStamp  } )      
    # create an array of labels by calling the name method on each animal
    graph.add(:series, "Discrete Heartrate", heartrates.map {|a| a.heartRate} ) 
    # graph.add(:user_data, :chart_type, "discrete" ) 
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
end
