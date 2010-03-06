module DialUpStatusesHelper

  # split the hash into multiple hashes. it can be saved simply by Model.create(hash) then
  #

  def split_dial_up_status_hash_and_create_tuples(hash)
    prime = {}
    alternate = {}
    global_prime = {}
    global_alternate = {}
    last_successful = {}
    #
    { "prime"            => "",
      "alternate"        => "alt_",
      "global_prime"     => "global_prim_",
      "global_alternate" => "global_alt_"
    }.each do |key, value|
      ["status", "configured",].each do |hash_key|
        eval("#{key}[:#{hash_key}] = hash[\"#{value}#{hash_key}\"]")
      end
      ["device_id", "num_failures", "consecutive_fails", "ever_connected"].each do |hash_key|
        eval("#{key}[:#{hash_key}] = hash[\"#{value}#{hash_key}\"].to_i")
      end
      # FIXME: structure is boolean, value received is integer
      eval("#{key}[:ever_connected] = (hash[\"#{value}ever_connected\"].to_i > 0)")
      eval("#{key}[:phone_number] = hash[\"#{value}number\"]") # similar pattern for all
      eval("#{key}[:device_id] = hash[\"device_id\"].to_i") # same for all
      # TODO: pending
    end
    #
    # dialup_type
    [prime, alternate].each {|which| which[:dialup_type] = 'Local'}
    [global_prime, global_alternate].each {|which| which[:dialup_type] = 'Global'}
    #
    # last successful

    last_successful[:device_id]                 = hash["device_id"].to_i
    last_successful[:last_successful_number]    = hash["last_successful_number"]
    last_successful[:last_successful_username]  = hash["last_successful_username"]
    last_successful[:last_successful_password]  = hash["last_successful_password"]
    #
    # get the hashes back to calling method
    [prime, alternate, global_prime, global_alternate].each do |tuple_hash|
      DialUpStatus.create!( tuple_hash) unless tuple_hash.blank? rescue nil
    end
    DialUpLastSuccessful.create!( last_successful) unless last_successful.blank? rescue nil
  end
end
