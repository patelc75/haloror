class Fall < ActiveRecord::Base
  belongs_to :user
  
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "#{user.name} fell on #{timestamp}"
  end
end
