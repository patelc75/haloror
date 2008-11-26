class CallCenterStep < ActiveRecord::Base
  belongs_to :call_center_group
  belongs_to :call_center_session
  
  def is_header?
    return !self.header.blank?
  end
end
