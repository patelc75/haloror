class MgmtAck < ActiveRecord::Base
  belongs_to :mgmt_cmd
  
  
  def self.new_initialize(random=false)
    model = self.new
    return model    
  end
  
  
end
