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

  
  #validates_length_of       :home_phone, :is => 10
  #validates_length_of       :work_phone, :is => 10, :if => :work_phone_exists?
  #validates_length_of       :cell_phone, :is => 10  

  #before_create             :check_phone_numbers

 #def check_phone_numbers
 # 	self.home_phone = self.home_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'')
 # 	self.work_phone = self.work_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'') if self.work_phone
 # 	self.cell_phone = self.cell_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'')
  	
  	#check_valid_phone_numbers
 #end

  def validate
  	errors.add(:home_phone," is the wrong length (should be 10 digits)") if self.home_phone != '' and phone_strip(self.home_phone).length != 10
  	errors.add(:work_phone," is the wrong length (should be 10 digits)") if self.work_phone != '' and phone_strip(self.work_phone).length != 10
  	errors.add(:cell_phone," is the wrong length (should be 10 digits)") if self.cell_phone != '' and phone_strip(self.cell_phone).length != 10
  end
  
  def phone_strip(phone)
	phone.tr("-().{}@~+=","").gsub(/[a-z]/,'')  	
  end

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
  
  def work_phone_exists?
   if self.work_phone.blank?
        return false
   else
      return true
   end
  end
  
  def phone_required?
    if unless_new_caregiver
      if self.home_phone.blank? && self.cell_phone.blank?
        return true
      end
    end
    return false
  end
  
 # private
  
 # def check_valid_phone_numbers
  #	errors.add(:home_phone," is the wrong length (should be 10 characters)") if home_phone.length != 10
 # 	return false
 # end
  
end
