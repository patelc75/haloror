class UserIntake < ActiveRecord::Base
  belongs_to :group
  has_and_belongs_to_many :users # replaced with has_many :through
  has_many :user_intakes_users, :dependent => :destroy
  # has_many :seniors, :through => :user_intakes_users, :source => :senior
  # has_many :subscribers, :through => :user_intakes_users, :source => :subscriber
  # has_many :caregivers, :through => :user_intakes_users, :source => :caregiver
  validates_numericality_of :order_id, :if => :order_present?
  # validates_associated :seniors, :subscribers, :caregivers
  # attr_accessor :group_id, :same_as_user, :add_as_caregiver, :monthly_or_card
  # attr_accessor :no_caregiver_1, :no_caregiver_2, :no_caregiver_3
  before_create :collect_users_for_save
  after_create :post_process_roles_and_options
  attr_accessor :mem_senior, :mem_subscriber, :mem_caregiver1, :mem_caregiver2, :mem_caregiver3
  attr_accessor :mem_caregiver1_options, :mem_caregiver2_options, :mem_caregiver3_options
  attr_accessor :subscriber_is_user, :subscriber_is_caregiver

  # for every instance, make sure the associated objects are built
  def after_initialize
    self.senior = User.new  if senior.blank?
    senior.build_profile    if senior.profile.blank?
    
    self.subscriber = User.new  if subscriber.blank?
    subscriber.build_profile    if subscriber.profile.blank?

    (1..3).each do |e|
      self.send("caregiver#{e}=", User.new) if self.send("caregiver#{e}").blank?
      caregiver = self.send("caregiver#{e}")
      caregiver.build_profile if caregiver.profile.blank?
    end
  end
  
  def collect_users_for_save
    senior.profile = nil if senior.profile.attributes.values.compact.blank? unless senior.profile.blank?
    self.senior = nil if senior.attributes.values.compact.blank?
    self.senior.skip_validation = true unless senior.blank?

    debugger
    self.users = [senior] # , subscriber, caregiver1, caregiver2, caregiver3
  end
  
  def post_process_roles_and_options
    # add roles and options
    # senior
    debugger
    senior.valid? ? senior.is_halouser_of( group) : self.errors.add_to_base("Senior not valid")
    self.errors.add_to_base("Senior profile needs more detail") unless senior.profile.valid? unless senior.profile.blank?
    # # subscriber
    # subscriber.valid? ? subscriber.is_subscriber_of(senior) : self.errors.add_to_base("Subscriber not valid")
    # self.errors.add_to_base("Subscriber profile needs more detail") unless subscriber.profile.valid?
    # # caregivers
    # (1..3).each_with_index do |number, index|
    #   caregiver = self.send("caregiver#{number}".to_sym)
    #   caregiver.valid? ? caregiver.is_caregiver_to(senior) : self.errors.add_to_base("Caregiver #{index} not valid")
    #   self.errors.add_to_base("Caregiver #{index} profile needs more detail") unless caregiver.profile.valid?
    #   options = caregiver.options_for_senior(senior)
    # end
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
      self.mem_senior # ||= User.new
    else
      self.mem_senior ||= (users.select {|user| user.is_halouser_of?(group) }.first) #  || User.new
    end
    mem_senior
  end
  
  def senior=(arg)
    if arg == nil
      self.mem_senior = nil
    else
      attributes = (arg.is_a?(User) ? arg.attributes : (arg.is_a?(Hash) ? arg : nil))
      unless attributes.blank?
        if self.new_record?
          self.mem_senior = User.new(attributes)
        else
          user = senior
          user.attributes = attributes
          user.is_halouser_of( group) # self.group
          self.mem_senior = user # keep in instance variable so that attrbutes can be saved with user_intake
        end
      end
    end
    self.mem_senior
  end

  def subscriber
    if subscriber_is_user
      self.mem_subscriber = senior # senior code handles everything. no caching, can change
    else
      if self.new_record?
        self.mem_subscriber ||= User.new
      else
        self.mem_subscriber ||= (users.select {|user| user.is_subscriber_of?(senior) }.first || User.new) # fetch first subscriber from users
      end
    end
    mem_subscriber
  end
  
  def subscriber=(arg)
    if subscriber_is_user
      self.mem_subscriber = self.senior = arg # senior code will handle this
    else
      attributes = (arg.is_a?(User) ? arg.attributes : (arg.is_a?(Hash) ? arg : nil))
      unless attributes.blank?
        attributes.merge(:skip_validation => true)
        if self.new_record?
          self.mem_subscriber = User.new(attributes)
        else
          user = subscriber
          user.attributes = attributes
          user.is_subscriber_of( senior) # self.senior
          self.mem_subscriber = user
        end
      end
    end
    self.mem_subscriber ||= User.new
    self.mem_subscriber.skip_validation = true
    self.mem_subscriber
  end
  
  def caregiver1
    if subscriber_is_caregiver
      self.mem_caregiver1 = subscriber # subscriber code handles everything
    else
      if self.new_record?
        self.mem_caregiver1 ||= User.new
      else
        self.mem_caregiver1 ||= (users.select {|user| user.options_attribute_for_senior(senior, "position") == 1}.first || User.new) # fetch caregiver1 from users
      end
    end
    mem_caregiver1
  end

  def caregiver1=(arg)
    if subscriber_is_caregiver
      self.mem_caregiver1 = self.subscriber = arg # subscriber code will handle this
    else
      attributes = (arg.is_a?(User) ? arg.attributes : (arg.is_a?(Hash) ? arg : nil))
      unless attributes.blank?
        attributes.merge(:skip_validation => true)
        if self.new_record?
          self.mem_caregiver1 = User.new(attributes)
        else
          user = caregiver1
          user.attributes = attributes
          user.is_caregiver_of( subscriber) # self.subscriber
          self.mem_caregiver1 = user
        end
      end
    end
    self.mem_caregiver1 ||= User.new
    self.mem_caregiver1.skip_validation = true
    self.mem_caregiver1
  end

  def caregiver2
    if self.new_record?
      self.mem_caregiver2 ||= User.new
    else
      self.mem_caregiver2 ||= (users.select {|user| user.options_attribute_for_senior(senior, "position") == 2}.first || User.new) # fetch caregiver2 from users
    end
    mem_caregiver2
  end

  def caregiver2=(arg)
    attributes = (arg.is_a?(User) ? arg.attributes : (arg.is_a?(Hash) ? arg : nil))
    unless attributes.blank?
      attributes.merge(:skip_validation => true)
      if self.new_record?
        self.mem_caregiver2 = User.new(attributes)
      else
        user = caregiver2
        user.attributes = attributes
        user.is_caregiver_of( subscriber) # self.subscriber
        self.mem_caregiver2 = user
      end
    end
    self.mem_caregiver2 ||= User.new
    self.mem_caregiver2.skip_validation = true
    self.mem_caregiver2
  end
  
  def caregiver3
    if self.new_record?
      self.mem_caregiver3 ||= User.new
    else
      self.mem_caregiver3 ||= (users.select {|user| user.options_attribute_for_senior(senior, "position") == 3}.first || User.new) # fetch caregiver3 from users
    end
    mem_caregiver3
  end

  def caregiver3=(arg)
    attributes = (arg.is_a?(User) ? arg.attributes : (arg.is_a?(Hash) ? arg : nil))
    unless attributes.blank?
      attributes.merge(:skip_validation => true)
      if self.new_record?
        self.mem_caregiver3 = User.new(attributes)
      else
        user = caregiver3
        user.attributes = attributes
        user.is_caregiver_of( subscriber) # self.subscriber
        self.mem_caregiver3 = user
      end
    end
    self.mem_caregiver3 ||= User.new
    self.mem_caregiver3.skip_validation = true
    self.mem_caregiver3
  end

  def caregivers_as_array
    [caregiver1, caregiver2, caregiver3]
  end
  
  def senior_attributes=(attributes)
    senior = attributes unless attributes.values.compact.blank?
  end
  
  def subscriber_attributes=(attributes)
    subscriber = attributes unless attributes.values.compact.blank?
  end
  
  def caregiver1_attributes=(attributes)
    caregiver1 = attributes unless attributes.values.compact.blank?
  end
  
  def caregiver2_attributes=(attributes)
    caregiver2 = attributes unless attributes.values.compact.blank?
  end
  
  def caregiver3_attributes=(attributes)
    caregiver3 = attributes unless attributes.values.compact.blank?
  end
end
