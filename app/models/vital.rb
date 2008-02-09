class Vital < ActiveRecord::Base
  def self.average_data(num_points, start_time, end_time)
    @series_data = Array.new(num_points, 0)  #results of averaging from database
    @categories = Array.new(num_points, 0) 
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on
    
    while current_point < num_points
      condition = "timestamp > '#{current_time}' AND timestamp < '#{current_time + interval}' AND user_id = '#{current_user_id}'"
      
	  #before inheritance
	  #average = Heartrate.average(:heartrate, :conditions => condition)
	  
	  #after inheritance
	  average = get_average(condition)
      
	  current_time = current_time + interval
	  
	  @series_data[current_point] = format_average(average)
	  @categories[current_point] = current_time.strftime("%H:%M:%S")
	  
      current_point = current_point + 1
      #@averages_array << round_to(average, 1)
	  #@averages_array <<  ((average * 10).truncate.to_f / 10)
      #@labels_array << current_time.strftime("%H:%M:%S")
    end 
    
	puts "above the loop"
    #for debugging
    @averages_array.each_with_index() do |x, i| 
      puts x, @labels_array[i]
	  puts "HW"
    end
  end
end
