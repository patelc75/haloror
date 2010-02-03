class Profile < ActiveRecord::Base
  
  acts_as_audited :except => [:is_caregiver, :is_new_caregiver]
  
  #composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  composed_of :tz, :class_name => 'TimeZone', :mapping => %w(time_zone identifier)
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
  validates_presence_of     :carrier_id, :if => :cell_phone_exists?, :message => "for Cell Phone can't be blank"

  validates_presence_of     :emergency_number_id,:if => :unless_new_halouser
  
  validates_length_of       :account_number, :maximum => 4,:if => :unless_new_halouser
  validates_length_of       :hospital_number, :maximum => 10,:if => :unless_new_halouser
  validates_length_of       :doctor_phone, :maximum => 10,:if => :unless_new_halouser
  
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
  def email=(email); nil; end
  def email; self.user.email; end

  def owner_user # for auditing
    self.user rescue nil
  end

 class << self # class methods

   # create profile for provided user. bypass all validations
   #
   def generate_for_online_customer(options = nil)
     unless options.blank?
       if options.is_a?(Integer) # direct user.id given
         user = User.find_by_id(options)
         first_name = last_name = (user.login.blank? ? user.email : user.login)
         
       elsif options.is_a?(User)
         user = options
         first_name = last_name = (user.login.blank? ? user.email : user.login)
         
       elsif options.is_a?(Hash) # multiple options supplied
         user = (options.key?(:user) ? options[:user] : (options.key?(:user_id) ? User.find_by_id(options[:user_id]) : nil))
         first_name = (options.key?(:first_name) ? options[:first_name] : (user.login.blank? ? user.email : user.login))
         last_name = (options.key?(:last_name) ? options[:last_name] : (user.login.blank? ? user.email : user.login))
       end
   
       unless user.blank?
         if user.profile.blank?
           profile = Profile.new(:first_name => first_name, :last_name => last_name)
           profile[:is_halouser] = false
           profile[:is_new_caregiver] = true
           profile[:user_id] = user.id
           profile.save!
         else
           profile = user.profile
         end
         profile
       end
     end
   end
 
 end # class methods

  def validate
  	if self[:is_new_caregiver]
      return false
    else
  	errors.add(:home_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.home_phone != '' and !self.home_phone.nil? and phone_strip(self.home_phone).length != 10 
  	errors.add(:work_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.work_phone != '' and !self.work_phone.nil? and phone_strip(self.work_phone).length != 10 
  	errors.add(:cell_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.cell_phone != '' and !self.cell_phone.nil? and phone_strip(self.cell_phone).length != 10
  	end
  end
  
  def phone_strip(phone)
  	phone_number = phone.tr("/[A-Z]/[a-z]/",'')
  	if phone_number == phone
	  phone.tr("-().","")  #.gsub(/[a-z]/,'').gsub(/[A-Z]/,'')
    else
      phone
    end
  end

  def unless_new_caregiver
    if self[:is_new_caregiver]
      return false
    else
      return true
    end
  end
  def unless_new_halouser
    if self[:is_halouser]
      return true
    else
      return false
    end
  end
  
  def cell_phone_exists?
    if self[:is_new_caregiver]
    	return false
    else
      if self.cell_phone.blank?
        return false
      else
      	return true
      end
    end
      
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
