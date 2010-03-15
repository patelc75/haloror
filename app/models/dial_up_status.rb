class DialUpStatus < ActiveRecord::Base
  belongs_to :device

  # instance variables to hold multiple row details from device hash, if present
  # we will use these to save separate rows of data during before_save
  attr_accessor :alternate, :global_prime, :global_alternate, :last_successful

  # define the attr_accessor for all attributes of device hash
  # this will avoid errors at initialize
  # "prime"            => "",    # not required. we are in the model and these are valid columns
  { 
    "alternate"        => "alt_",
    "global_prime"     => "global_prim_",
    "global_alternate" => "global_alt_"
  }.each do |key, value|
    [ "status", "configured", "device_id", "num_failures", "consecutive_fails", "ever_connected",
      "ever_connected", "phone_number", "number"].each do |hash_key|
        attr_accessor "#{value}#{hash_key}".to_sym
      end
  end
  attr_accessor :number, :timestamp # extra columns defined in XML
  attr_accessor :last_successful_number, :last_successful_username, :last_successful_password
  
  # filters, scopes

  # dynamically generated named scope
  #  by_dialup_type([...]), by_device_id([...]), ...
  # To degine more similar scopes, just add the column name symbl to the array
  [:dialup_type, :device_id].each do |which|
    named_scope "by_#{which}".to_sym, lambda { |*args|
      var = (args.blank? ? nil : args.flatten.first)
      { :conditions => (var.blank? ? {} : {which => var}) }
    }    
  end
  
  # triggers / hooks / callbacks
  
  # if the hash came from device, then parse it to instance variables
  def after_initialize
    self.alternate         = {}
    self.global_prime      = {}
    self.global_alternate  = {}
    self.last_successful   = {}
    # "prime"            => "",    # already assigned for this model from hash
    { 
      "alternate"        => "alt_",
      "global_prime"     => "global_prim_",
      "global_alternate" => "global_alt_"
    }.each do |key, value|
      ["status", "configured"].each do |hash_key|
        eval("self.#{key}[:#{hash_key}] = #{value}#{hash_key}")
      end
      ["device_id", "num_failures", "consecutive_fails", "ever_connected"].each do |hash_key|
        eval("self.#{key}[:#{hash_key}] = #{value}#{hash_key}.to_i")
      end
      # FIXME: structure is boolean, value received is integer
      eval("self.#{key}[:ever_connected] = (#{value}ever_connected.to_i > 0)")
      eval("self.#{key}[:phone_number] = #{value}number") # similar pattern for all
    end

    # dialup_type
    self.dialup_type = 'Local' # self
    self.alternate[:dialup_type] = 'Local'
    self.global_prime[:dialup_type] = 'Global'
    self.global_alternate[:dialup_type] = 'Global'

    # last successful
    self.last_successful[:device_id]                 = device_id.to_i
    self.last_successful[:last_successful_number]    = last_successful_number
    self.last_successful[:last_successful_username]  = last_successful_username
    self.last_successful[:last_successful_password]  = last_successful_password
  end


  # some more work after the row is saved to database
  #
  def after_create
    create_event

    # if we initiated this instance from a device hash, we have more work to do
    #
    # We save a few more rows that came in the hash
    # We did not save them earlier to avoid data inconsistency, just in case we decide not to save this instance
    # so the extra tuples go along "this" instance. all saved or none.
    #
    # WARNING: We have a drawback here
    #   We lose the callback to the Event.create_event for all these rows saved below
    #
    [self.alternate, self.global_prime, self.global_alternate].each do |tuple_hash|
      unless tuple_hash.blank?
          obj = DialUpStatus.new( tuple_hash)
          obj.send(:create_without_callbacks) # Otherwise endless recursion will happen
          create_event
      end
    end
    
    unless self.last_successful.blank?
        obj = DialUpLastSuccessful.new( self.last_successful)
        obj.send(:create_without_callbacks)
        create_event
    end
  end
  
  def create_event
    if (status == "fail" && consecutive_fails > 3 && configured == "old") or (status == "fail" && configured == "new") 
      device.users.each do |user|
        Event.create_event(user.id, self.class.name, id, created_at)
      end
    end
  end
# <<<<<<< HEAD
# 
#   # class methods
#   
#   def self.process_xml_hash(msg)
#     #
#     # get the hashes separate for each row of AR
#     prime, alternate, global_prime, global_alternate, last_successful = split_hashes_for_dialups(msg)
#     #
#     # create the AR now
#     [prime, alternate, global_prime, global_alternate].each {|which| DialUpStatus.create(which) }
#     #
#     # successful status. This has different attributes, therefore separate from others
#     DialUpLastSuccessful.create(last_successful)
# 
# #=======
  
  # class methods
  
  # def self.process_xml_hash(msg)
#>>>>>>> master-2548-dialup-status-bundle
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
  # end

  # instance methods
  
  def to_s
    "Dial Up failure for #{phone_number} at #{UtilityHelper.format_datetime(updated_at, device.users[0])}" 
  end

  def email_body
   	"Dial Up failure for #{phone_number} at #{UtilityHelper.format_datetime(updated_at, device.users[0])}"
  end
end
