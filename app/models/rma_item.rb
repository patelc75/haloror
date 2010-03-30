class RmaItem < ActiveRecord::Base
  belongs_to :rma
  belongs_to :device_model
  belongs_to :user
  belongs_to :group
  
  def user_name; return (user.blank? ? '' : user.full_name); end
  def group_name; return (group.blank? ? '' : group.name); end
  
  REASON_FOR_RETURN = ['Battery Issues',
  'Gateway Code',
  'No Sync',
  'Wearability',
  'Modem Upgrade', 
  'Software Upgrade', 
  'False Positives', 
  'Discontinued Use', 
  'Gateway Code', 
  'Transmitter Exchange', 
  'Hardware Defect',  
  'Other'  
  ]
  
  RmaItem::CONDITION_OF_RETURN = ['Like New',    
    'Slightly Used',
    'Basic Wear and Tear',
    'Never Used',
    'Destroyed',
    'Reason for Return'
  ]       
    
  RmaItem::ATP_STATUS = ['Pending',    
    'Fail',
    'Pass',
  ]
  
  # device_type_name
  #
  def type
    return (device_model.blank? ? '' : (device_model.model_type))
  end
end