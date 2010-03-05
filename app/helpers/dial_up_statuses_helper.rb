module DialUpStatusesHelper

  # split the hash into multiple hashes. it can be saved simply by Model.create(hash) then
  #
  def split_hashes_for_dialups(hash)
    prime = alternate = global_prime = global_alternate = last_successful = {}
    #
    { "prime"            => "",
      "alternate"        => "alt_",
      "global_prime"     => "global_prim_",
      "global_alternate" => "global_alt_"
    }.each do |key, value|
      [:status, :device_id, :configured, :num_failures, :consecutive_fails, :ever_connected].each do |hash_key|
        eval("#{key}[:#{hash_key}] = #{value}#{hash_key}")
      end
      eval("#{key}[:phone_number] = hash[:#{value}number]") # similar pattern for all
      eval("#{key}[:device_id] = hash[:device_id]") # same for all
      # TODO: pending
    end
    #
    # dialup_type
    [prime, alternate].each {|which| which[:dialup_type] = 'Local'}
    [global_prime, global_alternate].each {|which| which[:dialup_type] = 'Global'}
    #
    # last successful
    last_successful[:device_id]               = hash[:device_id]
    last_successful[:last_successful_number]  = hash[:last_successful_number]
    last_successful[:username]                = hash[:last_successful_username]
    last_successful[:password]                = hash[:last_successful_password]
    #
    # get the hashes back to calling method
    return prime, alternate, global_prime, global_alternate, last_successful
  end
end
