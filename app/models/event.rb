class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :alert_type
  
  acts_as_authorizable
  
  def string(user)
    strings = {'Fall' => 'Fell'}
    
    "#{user.profile.first_name} #{strings[self.event_type]}"
  end
end
