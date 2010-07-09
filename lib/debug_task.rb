# WARNING: code coverage required
class DebugTask
  include ActionView::Helpers::DateHelper

  # https://redmine.corp.halomonitor.com/issues/3168
  #   fetch rows and mgmt_queries
  def self.mgmt_query( device_id = nil)
    if device_id.blank? # when devices not defined, show how to use
      puts "Please specify a device_id"
      [] # do not return any data

    else
      # fetch appropriate mgmt_query rows, collect in an array
      MgmtQuery.find_all_by_device_id( device_id, :order => "timestamp_server DESC").collect do |row|
        "#{row.timestamp_device} | #{row.timestamp_server} | #{row.last.timestamp_server unless row.last.blank?} | #{row.time_span_since_last}"
        # include a header
      end.insert( 0, "Timestamp Device                | Timestamp Server                | Last Timestamp Server           | Delay server from last")
    end
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
  def self.local_failures( *user_ids)
    # when ids not given, select distinct user_ids after 2010-May-01
    conditions = ["timestamp >= ?", Time.mktime(2010, 05, 01)]
    # fetch user_ids if not given
    ( user_ids = HaloDebugMsg.all( :select => "DISTINCT user_id as user_id", :conditions => conditions).collect(&:user_id).compact.reject {|e| e == 0} ) if user_ids.blank?
    # check appropriate data for each user found
    User.all( :conditions => { :id => user_ids.flatten}).collect do |user|
      # fetch objects from database
      profile = user.profile unless user.blank?
      # fetch appropriate halo_debug_msg row
      (msg = user.halo_debug_msgs.all( :conditions => conditions, :order => "timestamp DESC").first) unless user.blank?
      # create a buffer to avoid lengthy conditions in string
      buffer = {} # define
      # collect data values in hash, for easy usage
      [:first_name, :last_name, :city, :state].each {|column| buffer[ column] = ( profile.blank? ? "not found" : profile.send( column).ljust(25)) }

      # generate string only when approriate msg row was found
      "#{buffer[:first_name].ljust(25)} | #{buffer[:last_name]} | #{buffer[:city].ljust(25)} | #{buffer[:state].ljust(25)} | #{msg.timestamp.to_s.ljust(25)}".gsub(/\n/,"") unless msg.blank?
      # include a header. avoid "nil" in result if msg row was not found
    end.insert( 0, ["First name".ljust(25), "Last name".ljust(25), "City".ljust(25), "State".ljust(25), "Timestamp".ljust(25) ].join(" | ")).compact
  end

end
