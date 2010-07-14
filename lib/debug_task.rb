# WARNING: code coverage required
class DebugTask
  include ActionView::Helpers::DateHelper

  # https://redmine.corp.halomonitor.com/issues/3168
  #   fetch rows and mgmt_queries
  # Usage:
  #   DebugTask.mgmt_query( 273)      # default: 1.week.ago
  #   DebugTask.mgmt_query( 273, 3.days.ago)
  #   DebugTask.mgmt_query( 273, 481 Time.mktime( 2010, 05, 01))
  #   DebugTask.mgmt_query( 273, 481, 254, Time.parse("3rd October, 2009"))
  def self.mgmt_query( *args)
    date_given = [DateTime, Time, Date, ActiveSupport::TimeWithZone].include?( args.last.class)
    date = ( date_given ? args.delete(args.last) : 1.week.ago) # last parameter can be date
    device_ids = (date_given ? args[0..-1] : args) # remaining args (once date is removed appropriately, or not)
    if device_ids.blank? # when devices not defined, show how to use
      puts "Please specify a device_id"
      [] # do not return any data

    else
      # fetch appropriate mgmt_query rows, collect in an array
      MgmtQuery.where_device_id( device_ids).since( date).all( :order => "timestamp_server DESC").collect do |row|
        "#{row.timestamp_device} | #{row.timestamp_server} | #{row.last.timestamp_server unless row.last.blank?} | #{row.time_span_since_last}".gsub(/\n/,"")
      end.insert( 0, "Timestamp Device                | Timestamp Server                | Last Timestamp Server           | Delay server from last") # include a header
    end
  end

  # https://redmine.corp.halomonitor.com/issues/3168
  # Usage:
  #   DebugTask.mgmt_query_delays   # default: since => 1.week.ago, threshold => 6.hours + 7.minutes, count => 4
  #   DebugTask.mgmt_query_delays( 1.week.ago, 6.hours + 7.minutes, 4)
  def self.mgmt_query_delays( since = 1.week.ago, threshold = (6.hours + 7.minutes), count = 4)
    mgmt_queries = MgmtQuery.since( since) # just a buffer. used later in this code
    device_ids = mgmt_queries.collect(&:device_id).compact.uniq.sort
    data = [["Device ID".ljust(10), "Timestamp Device".ljust(35), "Timestamp Server".ljust(35), "Last Timestamp Server".ljust(35), "Delay server from last".ljust(40), "Recent Timestamp".ljust(35)].join(" | ")]
    device_ids.each do |device_id|
      print '*' # keep user posted
      mgmt_queries.where_device_id( device_id).all( :order => "timestamp_server DESC").reject do |e|
        e.last.blank? # reject when this is the only row for device
      end.reject do |row|
        print '.' # to keep user posted
        ((row.timestamp_server - row.last.timestamp_server) < threshold.to_i) # reject rows that are within threshold
      end[0..count-1].each do |row| # only pick the "count" rows
        data << "#{row.device_id.to_s.ljust(10)} | #{row.timestamp_device.to_s.ljust(35)} | #{row.timestamp_server.to_s.ljust(35)} | #{(row.last.timestamp_server || '').to_s.ljust(35) unless row.last.blank?} | #{row.time_span_since_last.to_s.ljust(40)} | #{row.latest_timestamp_threshold_away(threshold).to_s.ljust(35)}".gsub(/\n/,"")
      end
    end
    data
  end

  # https://redmine.corp.halomonitor.com/issues/3168
  # Usage:
  #   DebugTask.numbers_in_use                # show how to use
  #   DebugTask.numbers_in_use( 6515)         # device_id
  #   DebugTask.numbers_in_use( 6515, 6516)   # array of device_ids
  def self.numbers_in_use( *device_ids)
    if device_ids.blank?
      puts "Please provide device_id or [device_id1, device_id2, ...]" # show how to use
      [] # do not return any data

    else
      # fetch devices from given ids. start collecting output data in array
      Device.find_all_by_id( device_ids.flatten).collect do |device|
        # fetch objects from database
        user = device.users.first unless device.users.blank? # fetch user for device
        profile = user.profile unless user.blank? # fetch profile
        # fetch appropriate msg row for user
        (msg = user.halo_debug_msgs.all( :conditions => ["description LIKE ?", "%Numbers in use%"], :order => "timestamp DESC").first) unless user.blank?
        # create a buffer to avoid lengthy conditions in string
        buffer = {}
        # collect data in hash for simpler subsctitution in string
        [:first_name, :last_name, :address, :city, :state].each {|column| buffer[ column] = ( profile.blank? ? "not found" : profile.send( column).ljust(25)) }

        # generate string output. collected in array and returned
        "#{buffer[:first_name].ljust(25)} | #{buffer[:last_name]} | #{buffer[:address].ljust(25)} | #{buffer[:city].ljust(25)} | #{buffer[:state].ljust(25)} | #{msg.timestamp.to_s.ljust(25)} | #{msg.description}".gsub(/\n/,"") unless msg.blank?
        # add a header. avoid "nil" in result if msg row was not found
      end.insert( 0, ["First name".ljust(25), "Last name".ljust(25), "Address".ljust(25), "City".ljust(25), "State".ljust(25), "Timestamp".ljust(25), "Description"].join(" | ")).compact

    end
  end

  # https://redmine.corp.halomonitor.com/issues/3168
  # Usage:
  #   DebugTask.local_failures              # fetch all users with appropriate halo_debug_msgs after 1-May-2010
  #   DebugTask.local_failures( 337)        # or any user_id
  #   DebugTask.local_failures( 337, 478)   # output only for an array of user_ids
  #   DebugTask.local_failures( 337, 478, 7.days.ago)   # output only for an array of user_ids
  #   DebugTask.local_failures( 337, 478, Time.mktime(2010, 05, 01))   # output only for an array of user_ids
  #   DebugTask.local_failures( 337, 478, Date.yesterday)   # output only for an array of user_ids
  def self.local_failures( *user_ids)
    user_ids.compact! # remove any "nil"
    # pick the date if argument given
    date = user_ids.delete(user_ids.last) if [DateTime, Time, Date, ActiveSupport::TimeWithZone].include? user_ids.last.class
    # when ids not given, select distinct user_ids after 2010-May-01
    conditions = ( date.blank? ? {} : ["timestamp >= ?", date.to_formatted_s(:db)] )
    # fetch user_ids if not given
    ( user_ids = HaloDebugMsg.all( :select => "DISTINCT user_id as user_id", :conditions => conditions).collect(&:user_id).compact.reject {|e| e == 0} ) if user_ids.blank?
    # check appropriate data for each user found
    result = User.all( :conditions => { :id => user_ids.flatten}).collect do |user|
      # fetch objects from database
      profile = user.profile unless user.blank?
      # fetch appropriate halo_debug_msg row
      unless user.blank?
        msgs = user.halo_debug_msgs.all( :conditions => conditions, :order => "timestamp DESC")
        msg = msgs.first unless msgs.blank?
      end
      # create a buffer to avoid lengthy conditions in string
      buffer = {} # define
      # collect data values in hash, for easy usage
      [:first_name, :last_name, :address, :city, :state].each {|column| buffer[ column] = ( profile.blank? ? "not found" : profile.send( column).ljust(25)) }

      # generate string only when approriate msg row was found
      ["#{buffer[:first_name].ljust(25)} | #{buffer[:last_name]} | #{buffer[:address].ljust(25)} | #{buffer[:city].ljust(25)} | #{buffer[:state].ljust(25)} | #{msg.timestamp.to_s.ljust(25)} | #{msgs.length.to_s.ljust(10)} | #{msg.description}".gsub(/\n/,""), msg.timestamp.to_formatted_s(:db)] unless msg.blank?
      # include a header. avoid "nil" in result if msg row was not found
    end

    unless result.blank?
      # sort by timestamp DESC for DebugTask.local_failures
      result = ( (result.length > 1) ? result.sort {|a,b| a[1] <=> b[1] }.reverse : result )
      result.collect {|e| e[0] }.compact.insert( 0, ["First name".ljust(25), "Last name".ljust(25), "Address".ljust(25), "City".ljust(25), "State".ljust(25), "Timestamp".ljust(25), "Count".ljust(10), "Description" ].join(" | ") )
    end
  end

end
