# WARNING: to get proper behavior from user_intake instance for the views
#   Always call user_intake.build_associations immediately after creating an instance
#
class UserIntake < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users # replaced with has_many :through
  has_many :user_intakes_users, :dependent => :destroy
  after_save :associations_after_save
  # hold the data temporarily
  # user type is identified by the role it has subject to this user intake and other users
  attr_accessor :mem_senior, :mem_subscriber, :need_validation
  (1..3).each do |index|
    attr_accessor "mem_caregiver#{index}".to_sym
    attr_accessor "mem_caregiver#{index}_options".to_sym
    attr_accessor "no_caregiver_#{index}".to_sym
  end

  # for every instance, make sure the associated objects are built
  def after_initialize
    self.need_validation = true # assume, the user will not hit "save"
    # find(id, :include => :users) does not work due to activerecord design the way it is
    #   AR should ideally fire a find_with_associations and then initialize each object
    #   AR is not initializing the associations before it comes to this callback, in rails 2.1.0 at least
    #   this means, the associations do exist in DB, and found in query, but not loaded yet
    # 
    #   workaround
    #     initialize the associations only for new instance. we are safe
    #     call user_intake.build_associations in the code on user_intake instance
    if self.new_record?
      self.subscriber_is_user = true
      self.subscriber_is_caregiver = false
      (1..3).each {|e| self.send("mem_caregiver#{e}_options=".to_sym, {"position" => e}) }
      build_associations
    end
  end
  
  def before_save
    associations_before_validation_and_save # build the associations
    validate_associations
  end
  # create blank placeholder records
  # required for user form input
  def build_associations
    self.senior = User.new if senior.nil?
    senior.build_associations unless senior.nil?
    
    self.subscriber = User.new if subscriber.nil?
    subscriber.build_associations unless subscriber.nil?

    (1..3).each do |index|
      caregiver = self.send("caregiver#{index}=".to_sym, User.new) if self.send("caregiver#{index}".to_sym).nil?
      caregiver.build_associations unless caregiver.nil?
    end
  end
  
  def skip_validation
    self.need_validation = false
  end
  
  def skip_validation=(value = false)
    self.need_validation = !value
    #
    # skip validations for all associated records
    [:senior, :subscriber, :caregiver1, :caregiver2, :caregiver3].each do |user_type|
      user = self.send(user_type)
      unless user.blank?
        user.send("skip_validation=", true)
        user.profile.skip_validation = true unless user.profile.blank?
      end
    end
  end
  
  def validate
    if need_validation
      associations_before_validation_and_save # pre-process associations
      validate_associations
    end
  end
  
  def validate_associations
    #
    # validate everything unless specific association are marked to skip
    if senior.blank?
      errors.add_to_base("Senior: profile is mnadatory")
    else
      errors.add_to_base("Senior: " + senior.errors.full_messages.join(', ')) unless (senior.skip_validation || senior.valid?)
      if senior.profile.blank?
        errors.add_to_base("Senior profile: is mnadatory") unless senior.skip_validation
      else
        errors.add_to_base("Senior profile: " + senior.profile.errors.full_messages.join(', ')) unless (senior.skip_validation || senior.profile.valid?)
      end
    end

    unless subscriber_is_user
      if subscriber.blank?
        errors.add_to_base("Subscriber: profile is mnadatory")
      else
        errors.add_to_base("Subscriber profile: " + subscriber.errors.full_messages.join(', ')) unless (subscriber.skip_validation || subscriber.valid?)
        if subscriber.profile.blank?
          errors.add_to_base("Subscriber profile: is mnadatory") unless subscriber.skip_validation
        else
          errors.add_to_base("Subscriber profile: " + subscriber.profile.errors.full_messages.join(', ')) unless (subscriber.skip_validation || subcriber.profile.valid?)
        end
      end
    end
    
  end
  
  # collapse any associations to "nil" if they are just "new" (nothing assigned to them after "new")
  def collapse_associations
    unless senior.nil?
      senior.collapse_associations
      senior.nothing_assigned? ? (self.senior = nil) : (self.senior.skip_validation = true)
    end

    unless subscriber.nil?
      subscriber.collapse_associations
      (subscriber.nothing_assigned? || subscriber_is_user) ? (self.subscriber = nil) : (self.subscriber.skip_validation = true)
    end
    
    (1..3).each do |index|
      caregiver = self.send("caregiver#{index}".to_sym)
      unless caregiver.nil?
        caregiver.collapse_associations
        if caregiver.nothing_assigned? || (index == 1 && subscriber_is_caregiver) || (self.send("no_caregiver_#{index}".to_sym) == "1")
          self.send("caregiver#{index}=".to_sym, nil)
        else
          user = self.send("caregiver#{index}")
          user.send("skip_validation=", true) unless user.nil?
        end
      end
    end
  end

  # pre-process data before validating
  # we are keeping senior, subscriber, ... in attr_accessor variables
  def associations_before_validation_and_save
    collapse_associations # make empty ones = nil
    # for remaining, fill login, password details only when login is empty
    ["senior", "subscriber", "caregiver1", "caregiver2", "caregiver3"].each {|user| autofill_login_details(user) }
    self.users = [senior, subscriber, caregiver1, caregiver2, caregiver3].uniq.compact # omit nil, duplicates
  end
  
  # create more data for the associations to keep them valid and associated
  # roles, options for roles
  def associations_after_save
    # add roles and options
    # senior
    unless senior.blank?
      senior.valid? ? senior.is_halouser_of( group) : self.errors.add_to_base("Senior not valid")
      self.errors.add_to_base("Senior profile needs more detail") unless senior.profile.nil? || senior.profile.valid?
    end
    # subscriber
    unless subscriber.blank?
      subscriber.valid? ? subscriber.is_subscriber_of(senior) : self.errors.add_to_base("Subscriber not valid")
      self.errors.add_to_base("Subscriber profile needs more detail") unless subscriber.profile.nil? || subscriber.profile.valid?
    end
    # caregivers
    (1..3).each do |index|
      caregiver = self.send("caregiver#{index}".to_sym)
      unless caregiver.blank?
        caregiver.valid? ? caregiver.is_caregiver_to(senior) : self.errors.add_to_base("Caregiver #{index} not valid")
        self.errors.add_to_base("Caregiver #{index} profile needs more detail") unless caregiver.profile.nil? || caregiver.profile.valid?
        # save options
        caregiver.options_for_senior(senior, self.send("mem_caregiver#{index}_options"))
      end
    end
  end
  
  def created_by_user_name
    User.find(self.created_by).name
  end

  def order_present?
    !order_id.blank?
  end
  
  # TODO: DRYness required here
  def senior
    if self.new_record?
      self.mem_senior
    else
      self.mem_senior ||= (users.select {|user| user.is_halouser_of?(group) }.first)
    end
    mem_senior
  end
  
  def senior=(arg)
    if arg == nil
      self.mem_senior = nil
    else
      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_senior = arg_user
        else
          user = (senior || arg_user)
          user.is_halouser_of( group) # self.group
          self.mem_senior = user # keep in instance variable so that attrbutes can be saved with user_intake
        end
        
        (self.mem_subscriber = mem_senior) if subscriber_is_user # link both to same data
      end
    end
    self.mem_senior
  end

  def subscriber
    if subscriber_is_user
      self.mem_subscriber = senior # pick senior, if self subscribed
    else
      if self.new_record?
        self.mem_subscriber
      else
        self.mem_subscriber ||= (users.select {|user| user.is_subscriber_of?(senior) }.first )
      end
    end
    mem_subscriber
  end
  
  def subscriber=(arg)
    if arg == nil
      self.mem_subscriber = nil
    else
      
      if subscriber_is_user
        self.mem_subscriber = self.senior = arg # assign to senior, then reference as subscriber
      else
        
        arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
        unless arg_user.blank?
          if self.new_record?
            self.mem_subscriber = arg_user # User.new(attributes)
          else
            user = (subscriber || arg_user)
            user.is_subscriber_of( senior) # self.senior
            self.mem_subscriber = user
          end
          
          # remember role option when subscriber is caregiver
          if subscriber_is_caregiver
            self.mem_caregiver1 = mem_subscriber
            (self.mem_caregiver1_options = attributes["role_options"]) if attributes.has_key?("role_options")
          end
        end
        
      end
    end
    self.mem_subscriber
  end
  
  def caregiver1
    if subscriber_is_caregiver
      self.mem_caregiver1 = subscriber # subscriber code handles everything
    else
      if self.new_record?
        self.mem_caregiver1
      else
        self.mem_caregiver1 ||= (users.select {|user| user.caregiver_position_for(senior) == 1}.first) # fetch caregiver1 from users
      end
    end
    mem_caregiver1
  end

  def caregiver1=(arg)
    if (arg == nil) || (!subscriber_is_caregiver && no_caregiver_1)
      self.mem_caregiver1 = nil
    else
      
      if subscriber_is_caregiver
        self.mem_caregiver1 = self.subscriber = arg # assign to subscriber, then reference as caregiver1
      else
        
        arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
        unless arg_user.blank?
          if self.new_record?
            self.mem_caregiver1 = arg_user # User.new(attributes)
          else
            user = (caregiver1 || arg_user)
            user.is_caregiver_of( senior) # self.senior
            self.mem_caregiver1 = user
          end
          
          self.mem_caregiver1_options = attributes["role_options"] if attributes.has_key?("role_options")
        end
        
      end
    end
    self.mem_caregiver1
  end

  def caregiver2
    if self.new_record?
      self.mem_caregiver2
    else
      self.mem_caregiver2 ||= (users.select {|user| user.caregiver_position_for(senior) == 2}.first) # fetch caregiver2 from users
    end
    mem_caregiver2
  end

  def caregiver2=(arg)
    if (arg == nil) || no_caregiver_2
      self.mem_caregiver2 = nil
    else

      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_caregiver2 = arg_user
        else
          user = (caregiver2 || arg_user)
          user.is_caregiver_of( senior) # self.senior
          self.mem_caregiver2 = user
        end

        self.mem_caregiver2_options = attributes["role_options"] if attributes.has_key?("role_options")
      end

    end
    self.mem_caregiver2
  end
  
  def caregiver3
    if self.new_record?
      self.mem_caregiver3
    else
      self.mem_caregiver3 ||= (users.select {|user| user.caregiver_position_for(senior) == 3}.first) # fetch caregiver3 from users
    end
    mem_caregiver3
  end

  def caregiver3=(arg)
    if (arg == nil) || no_caregiver_3
      self.mem_caregiver3 = nil
    else

      arg_user = argument_to_object(arg) # (arg.is_a?(User) ? arg : (arg.is_a?(Hash) ? User.new(arg) : nil))
      unless arg_user.blank?
        if self.new_record?
          self.mem_caregiver3 = arg_user
        else
          user = (caregiver3 || arg_user)
          user.is_caregiver_of( senior) # self.senior
          self.mem_caregiver3 = user
        end

        self.mem_caregiver3_options = attributes["role_options"] if attributes.has_key?("role_options")
      end

    end
    self.mem_caregiver3
  end

  def caregivers
    [caregiver1, caregiver2, caregiver3].uniq.compact
  end
  
  def senior_attributes=(attributes)
    self.senior = attributes
  end
  
  def subscriber_attributes=(attributes)
    (self.mem_caregiver1_options = attributes.delete("role_options")) if attributes.has_key?("role_options") && subscriber_is_caregiver
    self.subscriber = attributes
  end
  
  def caregiver1_attributes=(attributes)
    (self.mem_caregiver1_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
    self.caregiver1 = attributes
  end
  
  def caregiver2_attributes=(attributes)
    (self.mem_caregiver2_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
    self.caregiver2 = attributes
  end
  
  def caregiver3_attributes=(attributes)
    (self.mem_caregiver3_options = attributes.delete("role_options")) if attributes.has_key?("role_options")
    self.caregiver3 = attributes
  end
  
  private
  
  def autofill_login_details(user_type = "")
    unless user_type.blank?
      user = self.send("#{user_type}") # local copy, to keep code clean
      if !user.blank? && user.login.blank?
        hex = Digest::MD5.hexdigest(Time.now.to_s)[1..20]
        # only when user_type is not nil, but login is
        user.send("login=".to_sym, hex)
        user.send("password=".to_sym, hex)
        user.send("password_confirmation=".to_sym, hex)
      end
    end
  end

  def argument_to_object(arg)
    if arg.is_a?(User)
      arg
    else
      if arg.is_a?(Hash)
        User.new(arg)
      else
        nil
      end
    end
  end
end
