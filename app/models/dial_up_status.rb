class DialUpStatus < ActiveRecord::Base
  belongs_to :device
  
  # filters, scopes
  #
  # dynamically generated named scope
  #  by_dialup_type([...]), by_device_id([...]), ...
  # To degine more similar scopes, just add the column name symbl to the array
  [:dialup_type, :device_id].each do |which|
    named_scope "by_#{which}".to_sym, lambda { |*args|
      var = (args.blank? ? nil : args.flatten.first)
      { :conditions => (var.blank? ? {} : {which => var}) }
    }    
  end
  
  # triggers / hooks
  
  def after_create
    if (status == "fail" && consecutive_fails > 3 && configured == "old") or (status == "fail" && configured == "new") 
      device.users.each do |user|
        Event.create_event(user.id, self.class.name, id, created_at)
      end
    end
  end
  
  # class methods
  
  def self.process_xml_hash(msg)
    #
    # get the hashes separate for each row of AR
    prime, alternate, global_prime, global_alternate, last_successful = split_hashes_for_dialups(msg)
    #
    # create the AR now
    [prime, alternate, global_prime, global_alternate].each {|which| DialUpStatus.create(which) }
    #
    # successful status. This has different attributes, therefore separate from others
    DialUpLastSuccessful.create(last_successful)

    #     #Primary Number
    # DialUpStatus.create(:phone_number => request[:number],:status => request[:status],:device_id => request[:device_id],:configured => request[:configured],:num_failures => request[:num_failures],:consecutive_fails => request[:consecutive_fails],:ever_connected => request[:ever_connected],:dialup_type => 'Local')
    # 
    # #Local Alternative Number
    # DialUpStatus.create(:phone_number => request[:alt_number],:status => request[:alt_status],:device_id => request[:device_id],:configured => request[:alt_configured],:num_failures => request[:alt_num_failures],:consecutive_fails => request[:alt_consecutive_fails],:ever_connected => request[:alt_ever_connected],:dialup_type => 'Local')
    # 
    # #Global Primary Number
    # DialUpStatus.create(:phone_number => request[:global_prim_number],
    # :status => request[:global_prim_status],
    # :device_id => request[:device_id],
    # :configured => request[:global_prim_configured],
    # :num_failures => request[:global_prim_num_failures],
    # :consecutive_fails => request[:global_prim_consecutive_fails],
    # :ever_connected => request[:global_prim_ever_connected],
    # :dialup_type => 'Global')
    # 
    # #Global Alternative Number
    # DialUpStatus.create(:phone_number => request[:global_alt_number],:status => request[:global_alt_status],:device_id => request[:device_id],:configured => request[:global_alt_configured],:num_failures => request[:global_alt_num_failures],:consecutive_fails => request[:global_alt_consecutive_fails],:ever_connected => request[:global_alt_ever_connected],:dialup_type => 'Global')
    # 
    # #Last Successful Number
    # DialUpLastSuccessful.create(:device_id => request[:device_id],:last_successful_number => request[:last_successful_number],:last_successful_username => request[:last_successful_username],:last_successful_password => request[:last_successful_password])
  end

  # instance methods
  
  def to_s
    "Dial Up failure for #{phone_number} at #{UtilityHelper.format_datetime(updated_at, device.users[0])}" 
  end

  def email_body
   	"Dial Up failure for #{phone_number} at #{UtilityHelper.format_datetime(updated_at, device.users[0])}"
  end
end
