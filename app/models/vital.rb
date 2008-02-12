class Vital < ActiveRecord::Base

  belongs_to :user
  
  def self.latest_data(num_points, id)
    vital = find(:all , 
      :limit => num_points, 
      :order => "timestamp DESC", 
      :conditions => "user_id = '#{id}'").reverse
		
    @series_data = get_latest(vital)
    @categories =  vital.map {|a| a.timestamp.strftime("%H:%M:%S") }
	
    values = [@series_data,  @categories]
  end
  
  def self.average_data(num_points, start_time, end_time, id)
    @series_data = Array.new(num_points, 0)  #results of averaging from database
    @categories = Array.new(num_points, 0) 
    interval = (end_time - start_time) / num_points #interval returned in seconds
    current_time = start_time
    current_point = 0   #the data point that we're currently on

    while current_point < num_points
      condition = "timestamp > '#{current_time}' AND timestamp < '#{current_time + interval}' AND user_id = '#{id}'"

      #before inheritance
      #average = Heartrate.average(:heartrate, :conditions => condition)

      #after inheritance
      average = get_average(condition)
      

      
      current_time = current_time + interval

      #@series_data[current_point] = format_average(average)
      if(average == nil)
        @series_data[current_point] = 0
      elsif
        @series_data[current_point] = average.round(1)
      end
      @categories[current_point] = current_time.strftime("%H:%M:%S")

      current_point = current_point + 1
      #@averages_array << round_to(average, 1)
      #@averages_array <<  ((average * 10).truncate.to_f / 10)
      #@labels_array << current_time.strftime("%H:%M:%S")
    end 

    #     puts "above the loop"
    #     #for debugging
    #     @averages_array.each_with_index() do |x, i| 
    #       puts x, @labels_array[i]
    #       puts "HW"
    #     end
	
    values = [@series_data,  @categories]
  end

  def self.method_missing(methId, *args)
    method = methId.id2name.to_s
    method_action = method[0...method.index("_").to_i]
    case method_action
    when "average"
      column = method[method.index("_").to_i + 1..method.length]
      arguments = String.new
      arguments += args.join(", ") || nil.to_s
      # arguments += " and " if !arguments.empty?
      # arguments += 
      #ActiveRecord::Base.class_eval("#{column}.average(#{arguments})")
      class_eval("average(:#{column})")
    end
  end
end
