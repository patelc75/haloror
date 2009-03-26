class Profile < ActiveRecord::Base
  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  belongs_to :user
  belongs_to :carrier
  belongs_to :emergency_number
  
  
  validates_presence_of     :first_name, :if => :unless_new_caregiver
  validates_presence_of     :last_name, :if => :unless_new_caregiver
  validates_presence_of     :address, :if => :unless_new_caregiver
  validates_presence_of     :city, :if => :unless_new_caregiver
  validates_presence_of     :state, :if => :unless_new_caregiver
  validates_presence_of     :zipcode, :if => :unless_new_caregiver
  validates_presence_of     :time_zone  , :if => :unless_new_caregiver
  
  validates_presence_of     :home_phone, :if => :phone_required?, :message => 'or Cell Phone is required'
  validates_presence_of     :cell_phone, :if => :phone_required?, :message => 'or Home Phone is required'
  validates_presence_of     :carrier_id, :if => :cell_phone_exists?
  
  def unless_new_caregiver
    if self[:is_new_caregiver]
      return false
    else
      return true
    end
  end
  def cell_phone_exists?
    if unless_new_caregiver
      if self.cell_phone.blank?
        return true
      end
    end
      return false
  end
  
  def phone_required?
    if unless_new_caregiver
      if self.home_phone.blank? && self.cell_phone.blank?
        return true
      end
    end
    return false
  end
end
