class MgmtCmd < ActiveRecord::Base
  belongs_to :mgmt_response
  has_one :mgmt_ack
  has_one :mgmt_query
  
  belongs_to :device
  
  belongs_to :cmd, :polymorphic => true
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
  
  
  def self.pending_server_cmds_by_type(id, type)
    MgmtCmd.find(:all, :conditions => "device_id = #{id} and pending = true and originator = 'server' and cmd_type = '#{type}'")
  end
end
