class MgmtCmd < ActiveRecord::Base
  belongs_to :cmd, :polymorphic => true
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by"
  belongs_to :device
  belongs_to :mgmt_response
  belongs_to :user

  has_one :mgmt_ack
  has_one :mgmt_query
    
  named_scope :for_device_ids, lambda {|arg| { :conditions => { :device_id => arg } }}
  named_scope :of_types, lambda {|arg| { :conditions => { :cmd_type => arg } }}
  named_scope :pending_server_commands, :conditions => { :pending => true, :originator => "server" }
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end

  def before_save
    # ticket 3213: Add feature to populate user_id column in the mgmt_cmds table when the mgmt_cmd is issues. Apply to all types of mgmt cmds if possible
    # assign user_id if we have a device
    self.user_id = device.user_intake.senior.id if ( device && device.user_intake && device.user_intake.senior )
  end
  
  # CHANGED: should use ORM layer than direct SQL
  # EXTENDED:
  #   * can accept an ID or a array of IDs
  #   * ORM abstraction from database layer
  #   * secure from SQL injection
  #   * provide an array of ids, or a string that defines the ranges and arrays
  def self.pending( ids, types )
    # arrays can be accepted without further processing.
    ( ids = ids.to_s.parse_integer_ranges ) if ids.is_a?( String ) # parse if string was provided. use to_s to ensure string
    MgmtCmd.pending_server_commands.for_device_ids( ids ).of_types( types ) # search pending commands
    #
    # Old method call. Buggy and unsecure. Changed to new call above
    # MgmtCmd.find(:all, :conditions => "device_id = #{id} and pending = true and originator = 'server' and cmd_type = '#{type}'")
  end
end
