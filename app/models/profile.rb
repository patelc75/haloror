class Profile < ActiveRecord::Base

  acts_as_audited :except => [:is_caregiver, :is_new_caregiver]

  #composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w(time_zone identifier)
  composed_of :tz, :class_name => 'TimeZone', :mapping => %w(time_zone identifier)
  belongs_to :user
  belongs_to :carrier
  belongs_to :emergency_number
  attr_accessor :need_validation

  # 
  #  Wed Nov 24 01:57:41 IST 2010, ramonrails
  #   * TODO: DRY this more
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

  # 
  #  Sat May 28 04:58:01 IST 2011, ramonrails
  #   Usage:
  #   * contains( 'try') => first_name or last_name contains 'try'
  named_scope :contains, lambda {|arg| { :conditions => ["profiles.first_name LIKE ? OR profiles.last_name LIKE ?", "%#{arg}%", "%#{arg}%"] }}

  #def check_phone_numbers
  #  self.home_phone = self.home_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'')
  #  self.work_phone = self.work_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'') if self.work_phone
  #  self.cell_phone = self.cell_phone.squeeze.tr("-().{}@^~+=","").gsub(/[a-z]/,'')

  #check_valid_phone_numbers
  #end

  # =============
  # = callbacks =
  # =============
  
  def after_initialize
    self.need_validation = true # default = run validations
  end

  def validate
    if self.skip_validation
      true
    else
      if self[:is_new_caregiver]
        return false
      else
        # "length != 10" changed to "length < 10" for compatibility with user_intake_form
        errors.add(:home_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.home_phone != '' and !self.home_phone.nil? and phone_strip(self.home_phone).length < 10 
        errors.add(:work_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.work_phone != '' and !self.work_phone.nil? and phone_strip(self.work_phone).length < 10 
        errors.add(:cell_phone," is the wrong length (should be 10 digits) or contains invalid characters") if self.cell_phone != '' and !self.cell_phone.nil? and phone_strip(self.cell_phone).length < 10
      end
    end
  end

  # =================
  # = class methods =
  # =================
  
  # 
  #  Thu Nov 25 19:17:05 IST 2010, ramonrails
  #   * updated the logic
  #   * eliminates "HM<any other alpha character>"
  #   * Only searches within "HM<digits>"
  #  Mon Nov 29 22:46:12 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3796
  #   * we only consider the values with digits in it
  #   * any other pattern existing in the records, is ignored
  def self.last_account_number
    # # 
    # #  Thu Dec  2 02:57:34 IST 2010, ramonrails
    # #   * This will fail if account number has any alpahbet in it
    # Profile.first( :conditions => ["account_number LIKE ?", "____"], :order => "account_number DESC" )
    #   * fetch all profiles with account_number not blank
    #   * reject any alphabets or prefixed characters from each
    #   * collect the digit values that appear at the end of string
    #   * find the highest number within that
    #
    #   * minimize memory usage: just select account_number in query
    #   * collect array of all numbers
    #   * eliminate any blanks
    _numbers = Profile.all( :conditions => ["account_number <> '' AND account_number IS NOT NULL"], :select => "account_number").collect(&:account_number).compact
    #   * collect the numeric values embedded anywhere in that string
    #   * pick the highest value
    # 
    #  Thu Jan 13 03:00:24 IST 2011, ramonrails
    #   * Ticket #4008 note-2
    (_numbers.collect { |e| e.match(/^(\D*)(\d+)(\D*)$/) ? e.match(/^(\D*)(\d+)(\D*)$/)[2].to_i : nil }.compact.max) || 0
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

  # ====================
  # = instance methods =
  # ====================
  
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
    # 
    #  Wed Nov 24 02:17:59 IST 2010, ramonrails
    #   * make sure time zone is present
    #   * WARNING: default is not compatible with users outside this zone
    self.time_zone ||= 'Central Time (US & Canada)'
  end

  def after_save
    # auto increment account number if it starts with "HM"
    #   * account number is 3 places alphabets, then number
    #   * increment for halouser only
    #   * increment when blank
    # QUESTION: do we only want to update this for new_record?
    #           what happens to existing user with invalid account number?
    #   * FIXME: make it less expensive on performance
    # 
    #  Thu Dec  9 23:00:19 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3858
    #   * account number must be blank
    #   * user must be halouser
    if account_number.blank? && is_profile_of_halouser? # only for new records
     self.account_number = next_account_number
     self.send( :update_without_callbacks)
    end
  end

  def is_profile_of_halouser?
    #   * user is assigned to this profile
    #   * user row is saved to database
    #   * user is halouser (does not matter, of what?)
    !user.blank? && !user.new_record? && user.is_halouser?
  end

  # 
  #  Thu Nov 25 19:52:32 IST 2010, ramonrails
  #   * validity of account number to "nnnn", 4-digits exactly, or, <albhabets><number><alphabets>
  def valid_account_number?
    #   * cannot be blank
    #   * must match the pattern "...." where "." is 0-9
    #   * strictly, 4-digits only
    #  Thu Dec  9 23:04:39 IST 2010, ramonrails
    account_number.match(/^(\d{4})$/) || account_number.match(/^(\D*)(\d+)(\D*)$/)
    #   * CHANGED: HM... numbers? or any other existing format?
    #   *   match(/^(\D*)(\d+)(\D*)$/) will validate any existing HMxxx, xxxx, xxxxHM, HMxxxHM formats
    # !account_number.blank? && account_number.match(/^(\d+)$/) #  && (account_number.match(/^(\d+)$/)[1].to_i > 0)
  end

  def name
    [first_name, last_name].join(' ')
  end
  
  def email=(email); nil; end
  def email; self.user.email; end

  def owner_user # for auditing
    self.user rescue nil
  end

  # checks if any attribute was assigned a value after "new"
  # helps in user intake at least
  # examples:
  #    Profile.new.nothing_assigned? => true
  #    Profile.new(:first_name => "first name").nothing_assigned? => false
  def nothing_assigned?
    # we just check the absolute mandatory attributes to decide a blank or filled record
    #   some of these attributes have conditional validations
    #   at least one of them should have some value to call this record filled
    #   so, if all these attributes are blank, we consider nothing is assigned
    _options = [:first_name, :last_name, :address, :city, :state, :zipcode, :time_zone, :home_phone,
      :cell_phone, :carrier_id, :emergency_number_id, :account_number,
      :hospital_number, :doctor_phone].collect {|e| self.send(e).blank? }.compact.uniq
    (_options.length == 1) && !_options.include?( false)
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

  # 
  #  Thu Nov 25 19:08:20 IST 2010, ramonrails
  #   * updated to a more stable logic
  #   * better recognition of the HMnnnn pattern
  #   * keep at least 4 digits, but allow more than 4
  def next_account_number
    # # 
    # #  Mon Nov 29 23:48:23 IST 2010, ramonrails
    # #   * https://redmine.corp.halomonitor.com/issues/3796
    # #   * just pick the last nmuber and return next number
    # #
    # #   TODO: To avoid any such misunderstandings
    # #   * Chirag keeps ownership of business logic in feature files
    # #   * Ram keeps the ownership of keeping them green
    # if (last_profile = Profile.last_account_number)
    #   last_profile.account_number.to_i == 9999 ? "????" : "%04d" % (last_profile.account_number.to_i + 1)
    # else
    #   "????"
    # end
    
    "%04d" % (Profile.last_account_number + 1)
    # # _fetched = if (_number = Profile.last_account_number)
    # #   #   * first two characters are "HM"
    # #   #   * the last character is a digit?
    # #   if _number[0..1] == "HM" && (48..57).include?( _number[-1])
    # #     # Example: "HM0123".match(/^(\D+)(\d+)$/)[2]    => "0123"
    # #     #   * return the second match as fetched value
    # #     #   * result is integer
    # #     #   * increment the result by 1 => number that we want
    # #     _number.match(/^(\D+)(\d+)$/)[2].to_i + 1
    # #   end
    # # end
    # # if _fetched.blank?
    # #   #   * We do not have any number
    # #   #   * lets start with first
    # #   "HM0001"
    # # elsif _fetched < 1000 # last number is less than 4 digits?
    # #   #   * Force at least 4 digits
    # #   #   * Insert "0" prefixes to make 4 digits
    # #   #   * Example: _fetched = 1; this yields => "HM0002"
    # #   "HM" + ( "%04d" % _fetched)
    # # else
    # #   #   * More than 4 digits, can be accepted directly as to_s
    # #   "HM" + _fetched.to_s
    # # end
  end

  # private # --------------------------------------------------

  # def check_valid_phone_numbers
  # errors.add(:home_phone," is the wrong length (should be 10 characters)") if home_phone.length != 10
  #  return false
  # end

end
