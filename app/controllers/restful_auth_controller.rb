class RestfulAuthController < ApplicationController
 require "digest/sha2"
  make_resourceful do 
    actions :all
    
    response_for :create do |format|
      format.xml { head :ok }  
    end
    
    response_for :create_fails do |format|
      format.xml {head :internal_server_error }
    end
  end
  session :off
  layout nil
  
  DEFAULT_HASH_KEY="226f3834726d5531683d4f4b5a2d202729695853662543375c226c6447"
  def authenticated?
    if action_name == 'create'
      return authorize
    else
      return false
    end
  end
  
  def authorize
    timestamp = get_hash_value_from_array([:timestamp, :begin_timestamp], params)
    #puts "timestamp #{timestamp}"
    if(params[:gateway_id])
      serial_num = Device.find(params[:gateway_id].to_i).serial_number;
      raise "Auth failed: timestamp missing" if timestamp == nil
      raise "Auth failed: hash check failed " unless is_hash_valid?(timestamp.strip + serial_num.strip, params[:auth])
    else
      cmd_type = get_hash_value_from_array([:cmd_type], params)
      originator = get_hash_value_from_array([:originator], params)
      
      raise "Auth failed: gateway_id missing" unless cmd_type == "device_registration" or originator == "server" or cmd_type == "user_registration"
    end
  end
  
  private
  def get_hash_value(key, hsh)
    if hsh[key]
      # if key is found return value
      #puts "return hsh[key]" + hsh[key]
      return hsh[key]
    else
      # else check values for class type of Hash and recurse
      hsh.each_value do |value|
        #puts "value" + value.to_s
        if value.class == HashWithIndifferentAccess
          ts = get_hash_value(key, value)
          #puts "ts" + ts
          return ts if ts
        end
      end
    end
    return nil
  end
  
  def get_hash_value_from_array(keys, hsh)
    keys.each {|k| return hsh[k] if hsh[k]}
    hsh.each_value do |value|
      if value.class == HashWithIndifferentAccess
        ts = get_hash_value_from_array(keys, value)
        return ts if ts
      end
    end
    return nil
  end
  
  def is_hash_valid?(string, hash)
    puts hash
    #return true if hash == Digest::SHA256.hexdigest(DEFAULT_HASH_KEY + string)
    return true if hash == Digest::SHA256.hexdigest(string)
    #Digest::SHA256.hexdigest(226f3834726d5531683d4f4b5a2d202729695853662543375c226c6447 + "Mon Dec 25 15:52:55 -0600 2007")
  end
end
