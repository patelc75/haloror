class Group < ActiveRecord::Base
  acts_as_authorizable
  has_many :emergency_numbers
  has_many :recurring_charges
  has_many :rmas
  has_many :system_timeouts
  validates_format_of :name, :with => /\A[a-z0-9_]+\z/, :message => 'Only lowercase and numeric characters are allowed'
  
  def get_timeout(mode, column)
  	st = self.system_timeouts.find_by_mode(mode)
  	return st ? st.send(column) : false
  end
  
end