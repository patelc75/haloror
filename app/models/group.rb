class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :emergency_numbers
  has_many :recurring_charges
  
  validates_format_of :name, :with => /\A[a-z0-9_]+\z/, :message => 'Only lowercase and numeric characters are allowed'
  
end