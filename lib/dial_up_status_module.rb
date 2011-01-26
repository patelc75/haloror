# https://redmine.corp.halomonitor.com/issues/3255
#   * strange issue of not updating the database column correctly when called within the model itself
#   * this module is created to help create multiple dial_up_status rows from one received XML hash
module DialUpStatusModule
  
  def save_dial_up_status_hash( hash)
    #
    # split the XML into hashes for database records
    local             = {}
    alternate         = {}
    global_prime      = {}
    global_alternate  = {}
    last_successful   = {}
    # "prime"            => "",    # already assigned for this model from hash
    { 
      "local"            => "",
      "alternate"        => "alt_",
      "global_prime"     => "global_prim_",
      "global_alternate" => "global_alt_"
    }.each do |key, value|
      #
      # https://redmine.corp.halomonitor.com/issues/3189
      # 
      #  Thu Jan 13 23:43:54 IST 2011, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/4002
      ["status", "configured", "username", "password"].each do |hash_key|
        eval("#{key}[:#{hash_key}] = hash['#{value}#{hash_key}']")
      end
      #
      # https://redmine.corp.halomonitor.com/issues/3189
      #   * https://redmine.corp.halomonitor.com/issues/4002
      # , "ever_connected"
      ["num_failures", "consecutive_fails"].each do |hash_key|
        eval("#{key}[:#{hash_key}] = hash['#{value}#{hash_key}'].to_i")
      end
      #
      # FIXME: structure is boolean, value received is integer
      #   * Custom patterns
      eval("#{key}[:ever_connected] = ((hash['#{value}ever_connected'].downcase.strip == 'true') || (hash['#{value}ever_connected'].to_i > 0))")
      eval("#{key}[:phone_number] = hash['#{value}number']") # similar pattern for all
      # # 
      # #  Tue Jan 11 03:34:09 IST 2011, ramonrails
      # #   * https://redmine.corp.halomonitor.com/issues/4002
      # #   * This is a boolean, so anything more than zero is TRUE
      # eval("#{key}[:ever_connected] = (hash['ever_connected'].to_i > 0)")
      # 
      #  Wed Dec 22 22:33:56 IST 2010, ramonrails
      #   * https://redmine.corp.halomonitor.com/issues/3901
      #   * columns shifted from dial_up_statuses to dial_up_last_successfuls
      # # https://redmine.corp.halomonitor.com/issues/3189
      # # common fields without prefix
      # ["lowest_connect_rate", "longest_dial_duration_sec"].each do |hash_key|
      #   eval("#{key}[:#{hash_key}] = hash['#{hash_key}'].to_i")
      # end
      # #
      # ["lowest_connect_timestamp", "longest_dial_duration_timestamp"].each do |hash_key|
      #   eval("#{key}[:#{hash_key}] = hash['#{hash_key}']")
      # end
    end

    # device_id is same
    [local, alternate, global_prime, global_alternate].each do |e|
      e[:device_id] = hash["device_id"]
      e[:timestamp] = hash["timestamp"] # https://redmine.corp.halomonitor.com/issues/4087
    end
    
    # dialup_type
    local[:dialup_type]            = 'Local' # self
    alternate[:dialup_type]        = 'Local'
    global_prime[:dialup_type]     = 'Global'
    global_alternate[:dialup_type] = 'Global'

    local[:dialup_rank]            = 'Primary' # self
    alternate[:dialup_rank]        = 'Alternate'
    global_prime[:dialup_rank]     = 'Primary'
    global_alternate[:dialup_rank] = 'Alternate'

    # last successful
    last_successful[:timestamp]                 = hash["timestamp"] # https://redmine.corp.halomonitor.com/issues/4087
    last_successful[:device_id]                 = hash["device_id"].to_i
    last_successful[:last_successful_number]    = hash["last_successful_number"]
    last_successful[:last_successful_username]  = hash["last_successful_username"]
    last_successful[:last_successful_password]  = hash["last_successful_password"]
    # 
    #  Wed Dec 22 22:33:56 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3901
    #
    last_successful[:lowest_connect_rate]             = hash["lowest_connect_rate"].to_i # integer
    last_successful[:lowest_connect_timestamp]        = hash["lowest_connect_timestamp"]
    last_successful[:longest_dial_duration_sec]       = hash["longest_dial_duration_sec"].to_i # integer
    last_successful[:longest_dial_duration_timestamp] = hash["longest_dial_duration_timestamp"]
    
    # now create the database rows
    #   * callbacks will also fire correctly
    #   * no need to particularly assign created_at, ...
    #   * device_id is same for all
    [local, alternate, global_prime, global_alternate].each {|e| DialUpStatus.create( e) }
    DialUpLastSuccessful.create( last_successful)
  end
end
