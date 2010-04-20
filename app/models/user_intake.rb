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
  after_save :post_process_roles_and_options
  attr_accessor :mem_senior, :mem_subscriber, :mem_caregiver1, :mem_caregiver2, :mem_caregiver3
  attr_accessor :mem_caregiver1_options, :mem_caregiver2_options, :mem_caregiver3_options

  # for every instance, make sure the associated objects are built
  # def after_initialize
  #   self.senior = User.new(:email => "senior@example.com") if self.senior.blank?
  #   self.subscriber = User.new(:email => "subscriber@example.com") if self.subscriber.blank?
  #   # (3-self.caregivers.size).times { self.caregivers.build(:email => "caregiver@example.com") }
  # end
  
  def post_process_roles_and_options
    [:senior, :subscriber, :caregiver1, :caregiver2, :caregiver3].each do |e|
      self.send(e).save unless self.send(e).attributes.values.compact.blank?
    end
    # add roles and options
    # senior
    senior.valid? ? senior.is_halouser_of( group) : self.add_to_base("Insufficient information about Senior")
    self.add_to_base(...) unless senior.profile.valid?
    # subscriber
    subscriber.is_subscriber_of(senior)
    # caregivers
    (1..3).each_with_index do |number, index|
      caregiver = self.send("caregiver#{number}".to_sym)
      caregiver.is_caregiver_of(senior) if caregiver.valid?
      options = caregiver.options_for_senior(senior)
      unless options.blank?
        ...
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
      self.mem_senior ||= User.new
    else
      self.mem_senior ||= (users.select {|user| user.is_halouser_of?(group) }.first || User.new) # fetch first halouser from users
    end
    mem_senior
  end
  
  def senior=(arg)
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
    self.mem_senior ||= User.new
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
  end

  def senior_attributes=(attributes)
    senior = attributes # build
  end
  
  def subscriber_attributes=(attributes)
    subscriber = attributes # build
  end
  
  def caregiver1_attributes=(attributes)
    caregiver1 = attributes
  end
  
  def caregiver2_attributes=(attributes)
    caregiver2 = attributes
  end
  
  def caregiver3_attributes=(attributes)
    caregiver3 = attributes
  end
end
