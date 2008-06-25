class Event < ActiveRecord::Base
  belongs_to :user
  #belongs_to :alert_type
  
  belongs_to :event, :polymorphic => true
  
  has_many :event_actions
  
  acts_as_authorizable
  
  def string(user)
    strings = {'Fall' => 'Fell'}
    
    # "#{user.profile.first_name} #{strings[self.event_type]}"
    "#{user.profile.first_name}: #{self.event_type}"
  end
  
  def accepted?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'accepted'
    end
    
    return false
  end
  
  def resolved?
    EventAction.find(:all, :conditions => "event_id = '#{self.id}'").each do |action|
      return action if action.description == 'resolved'
    end
    
    return false
  end
end
