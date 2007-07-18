require 'ziya'

class ChartController < ApplicationController
  include Ziya
  
  def line
   
  end
  
  def line_chart      
    graph  = Ziya::Charts::Line.new( nil, nil, "heartrate" ) #write up this line in the blog
    
    heartrates = Heartrate.find(:all)     # get information from the database
    graph.add(:axis_category_text, heartrates.map {|a| a.timeStamp  } )      
    # create an array of labels by calling the name method on each animal
    graph.add(:series, "Heartrate", heartrates.map {|a| a.heartRate} ) 
    render :xml => graph.to_s
  end  
end
