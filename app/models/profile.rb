class Profile < ActiveRecord::Base

  acts_as_audited :except => [:is_caregiver, :is_new_caregiver]

  #composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  composed_of :tz, :class_name => 'TimeZone', :mapping => %w(time_zone identifier)
  belongs_to :user
  belongs_to :carrier
  belongs_to :emergency_number
  attr_accessor :need_validation

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
  #  self.home_phone = self.home_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'')
  #  self.work_phone = self.work_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'') if self.work_phone
  #  self.cell_phone = self.cell_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'')

  #check_valid_phone_numbers
  #end

  def after_initialize
    self.need_validation = true # default = run validations
  end

  # not required. we can check profile account number directly
  # # cache fields in user
  # def after_save
  #   unless user.blank?
  #     self.user.has_no_call_center_account = account_number.blank?
  #     # WARNING. need to check if this might cause a recursive update
  #     # update_without_callbacks should eliminate recursion
  #     user.update_without_callbacks unless user.new_record? # else do not bother, user in memory has the data. it will save
  #   end
  # end

  def skip_validation
    !need_validation
  end

  def skip_validation=(value = false)
    self.need_validation = !value
  end

  def before_save
    # auto increment account number if it starts with "HM"
    #   * account number is 3 places alphabets, then number
    self.account_number = next_account_number if self.new_record? # only for new records
  end

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
            # WARNING: DEPRECATED :is_new_halouser, :is_new_user, :is_new_subscriber, :is_new_caregiver
            # CHANGED: we can now use user_intake object to create users and profiles
            # example:
            #  profile_attributes = Profile.new({...}).attributes
            #  user_attributes = User.new({..., :profile_attributes => profile_attributes}).attributes
            #  user_intake = UserIntake.new(:senior_attributes => user_attributes) # includes profile attributes
            #    or
            #  user_intake = UserIntake.new(:senior_attributes => User.new({:email => ..., :profile_attributes => Profile.new({...}).attributes}).attributes)
            profile[:is_new_halouser] = false # WARNING: deprecated
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

  # instance methods ------------------------------------------------

  # checks if any attribute was assigned a value after "new"
  # helps in user intake at least
  # examples:
  #    Profile.new.nothing_assigned? => true
  #    Profile.new(:first_name => "first name").nothing_assigned? => false
  def nothing_assigned?
    attributes.values.compact.blank?
  end

  def validate
    if self[:is_new_caregiver]
      return false
    else
      # "length != 10" changed to "length < 10" for compatibility with user_intake_form
      errors.add(:home_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.home_phone != '' and !self.home_phone.nil? and phone_strip(self.home_phone).length < 10 
      errors.add(:work_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.work_phone != '' and !self.work_phone.nil? and phone_strip(self.work_phone).length < 10 
      errors.add(:cell_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.cell_phone != '' and !self.cell_phone.nil? and phone_strip(self.cell_phone).length < 10
    end
  end

  def phone_strip(phone)
    phone_number = phone.tr("/[A-Z]/[a-z]/",'')
    if phone_number == phone
      phone.tr("-().","")  #.gsub(/[a-z]/,'').gsub(/[A-Z]/,'')
    elsif phone.size == 10
      phone + "invalid"
    else
      phone
    end
  end

  def unless_new_caregiver
    # cannot skip validation + not is_new_caregiver = run validations
    !(skip_validation || self[:is_new_caregiver])
    # if (skip_validation || self[:is_new_caregiver])
    #   return false
    # else
    #   return true
    # end
  end

  def unless_new_halouser
    # cannot skip validation? + is_halouser? = run validations
    (skip_validation ? false : self[:is_halouser])
    # if self[:is_halouser] # WARNING: :is_halouser is a mis-type?
    #   return true
    # else
    #   return false
    # end
  end

  def cell_phone_exists?
    # cannot skip validation? + not new caregiver = check existance of cell phone
    ( (skip_validation || self[:is_new_caregiver]) ? false : !cell_phone.blank? )
    # if (skip_validation || self[:is_new_caregiver])
    #   return false
    # else
    #   if self.cell_phone.blank?
    #     return false
    #   else
    #     return true
    #   end
    # end
  end

  def work_phone_exists?
    # work phone is not blank?
    !work_phone.blank?
    # if self.work_phone.blank?
    #      return false
    # else
    #    return true
    # end
  end

  def phone_required?
    if unless_new_caregiver
      if self.home_phone.blank? && self.cell_phone.blank?
        return true
      end
    end
    return false
  end

  private # --------------------------------------------------

  # WARNING: test required
  def next_account_number
    #
    # ordered account_numbers would ideally have the list in chronological order
    if (last_profile = Profile.first( :conditions => ["account_number LIKE ?", "HM%"], :order => "account_number DESC" ))
      call_center = last_profile.account_number
      #
      # extract SSSNNN where SSS = string, NNN = number
      # get the next number and assign it bak
      call_center[0..2] + (call_center.to_i + 1).to_s
    else
      'HM001' # this is the first one if the last profile was not found. correct?
    end
  end

  # def check_valid_phone_numbers
  # errors.add(:home_phone," is the wrong length (should be 10 characters)") if home_phone.length != 10
  #  return false
  # end

end
