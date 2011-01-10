class SandboxController < ApplicationController
  #layout "application", :except => "chart"

  #use this method to debug Rufus jobs
  #run server like this: ruby script/server -p 3001 --debugger
  def ruby_debug
    #CriticalMailer.deliver_device_not_worn_daily()
    #MgmtQuery.job_gw_offline
    #MgmtQuery.job_gw_offline
    Email.notify_by_priority
    # DeviceAlert.job_process_crtical_alerts() #Rufus job
    #BundleJob.process_xml_file("dialup/H200000025_1258657676_2.xml") #Rufus job
    #BatteryReminder.send_reminders()
		#BatteryReminder.create(:device_id => 215, 
							   #:reminder_num => 3,
							   #:user_id => 278,
							   #:time_remaining => 1000,
							   #:battery_critical_id => 7014)
  end
  
  def ethernet_users
    #code to run in script/console
    #total number of live non-demo ethernet users
    Device.ethernets.gateways.each { |d| puts (d.users[0].id.to_s + "\t" + d.users[0].name + " \t\t" + d.id.to_s + "\t" + d.serial_number.to_s) if !d.users[0].nil? and d.users[0].status == "Installed" and d.users[0].demo_mode != true }; 0
    Device.dialups.gateways.each { |d| puts (d.users[0].id.to_s + "\t" + d.users[0].name + " \t\t" + d.id.to_s + "\t" + d.serial_number.to_s) if !d.users[0].nil? and d.users[0].status == "Installed" and d.users[0].demo_mode != true }; 0        
  end
        
  def weight_scale_debugging
    ws = WeightScale.find(:first,:conditions => "user_id = '230' AND timestamp <= '#{Time.now.to_s}'",:order => 'timestamp desc')
    ws[:weight_unit]
  end
  
  def helloworld
    @heartrate = Heartrate.new
    @display = 0
    render :layout => false
  end
  
  def hello_world_submit
    @display = params[:chart][:dummy]
    render :layout => false
  end
  
  def critical_email
    email = CriticalMailer.panic_notification
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

  def assign_role
    User.find(17).has_role 'halouser'
  end
  
  def current
    @recentHeartRate = Heartrate.find(:first, :order => 'id DESC')
    @currentHeartRate = @recentHeartRate.heartRate
  end
end