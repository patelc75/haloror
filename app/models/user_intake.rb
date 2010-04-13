class UserIntake < ActiveRecord::Base
  has_and_belongs_to_many :users # replaced with has_many :through
  has_many :user_intakes_users, :dependent => :destroy
  # has_many :seniors, :through => :user_intakes_users, :source => :senior
  # has_many :subscribers, :through => :user_intakes_users, :source => :subscriber
  # has_many :caregivers, :through => :user_intakes_users, :source => :caregiver
	validates_numericality_of :order_id, :if => :order_present?
  # validates_associated :seniors, :subscribers, :caregivers
  # attr_accessor :group_id, :same_as_user, :add_as_caregiver, :monthly_or_card
  # attr_accessor :no_caregiver_1, :no_caregiver_2, :no_caregiver_3

  # for every instance, make sure the associated objects are built
  def after_initialize
    self.senior = User.new(:email => "senior@example.com") if self.senior.blank?
    self.subscriber = User.new(:email => "subscriber@example.com") if self.subscriber.blank?
    (3-self.caregivers.size).times { self.caregivers.build(:email => "caregiver@example.com") }
  end
	
  def created_by_user_name
  	User.find(self.created_by).name
  end

  def order_present?
    !order_id.blank?
    # false
    # unless order_id.blank?
    #   true
    # end
  end
  
  # TODO: DRYness required here
  def senior
    users.select {|user| user.is_halouser? }.first # fetch first halouser from users
    # seniors.blank? ? nil : seniors.first
  end
  
  def senior=(arg)
    attributes = arg.is_a?(User) ? arg.attributes : arg
    self.senior.attributes = attributes
    # arg = arg.attributes if arg.is_a? Senior
    # if self.seniors.blank?
    #   self.seniors.build(arg)
    # else
    #   self.seniors.first.attributes = arg
    # end
  end

  def subscriber
    users.select {|user| user.is_subscriber? }.first # fetch first subscriber from users
    # subscribers.blank? ? nil : subscribers.first
  end
  
  def subscriber=(arg)
    attributes = arg.is_a?(User) ? arg.attributes : arg
    self.subscriber.attributes = attributes
    # arg = arg.attributes if arg.is_a? Subscriber
    # if self.subscribers.blank?
    #   self.subscribers.build(arg)
    # else
    #   self.subscribers.first.attributes = arg
    # end
  end

  def caregiver1
    users.select {|user| user.options_for_senior(senior).position == 1 }
  end

  def caregiver2
    users.select {|user| user.options_for_senior(senior).position == 2 }
  end

  def caregiver3
    users.select {|user| user.options_for_senior(senior).position == 3 }
  end

  def caregivers
    [caregiver1, caregiver2, caregiver3]
  end
  
  def senior_attributes=(attributes)
    senior = attributes # build
  end
  
  def subscriber_attributes=(attributes)
    subscriber = attributes # build
  end

  def caregiver1_attributes(attributes)
    caregiver1 = attributes
  end

  def caregiver2_attributes(attributes)
    caregiver2 = attributes
  end

  def caregiver3_attributes(attributes)
    caregiver3 = attributes
  end
  # def caregiver_attributes=(caregiver_attributes)
  #   caregiver_attributes.each do |attributes|
  #     self.caregivers.build(attributes) # build
  #   end
  # end
end
