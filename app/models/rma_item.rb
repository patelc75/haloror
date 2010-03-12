class RmaItem < ActiveRecord::Base
  belongs_to :rma
  belongs_to :device_model
  belongs_to :user
  belongs_to :group
  
  def user_name; return (user.blank? ? '' : user.full_name); end
  def group_name; return (group.blank? ? '' : group.name); end
  
  # device_type_name
  #
  def type
    return (device_model.blank? ? '' : (device_model.model_type))
  end
end