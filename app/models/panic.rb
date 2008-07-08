class Panic < ActiveRecord::Base
  belongs_to :user
  include Priority
  def priority
    return IMMEDIATE
  end
  
  def to_s
    "#{user.name} panicked on #{timestamp}"
  end
end
