require 'ruleby'
class CallCenterWizard < ActiveRecord::Base
  belongs_to :call_center_session
  belongs_to :event
  belongs_to :user
  
  after_create :generate_call_center_steps
  
  USER_HOME_PHONE       = "Home Phone Answered?"        
  USER_MOBILE_PHONE     = "Mobile Phone Answered?"     
  CAREGIVER_HOME_PHONE  = "Caregiver Home Phone Answered?" 
  CAREGIVER_WORK_PHONE  = "Caregiver Work Phone Answered?"
  CAREGIVER_MOBILE_PHONE = "Caregiver MOBILE Phone Answered?"
  AMBULANCE             = "Ambulance Needed?"           
  ON_BEHALF             = "Ask if they will call 911 on behalf of halouser?"
  AGENT_CALL_911        = "Agent Call 911" 
  AMBULANCE_DISPATCHED  = "Ambulance Dispatched"
  THE_END               = "Resolve the Event"
  
  
  
  
  include Ruleby
  def first_step()
    self.call_center_session.call_center_steps.sort! do |a, b|
      a.created_at <=> b.created_at
    end
	  return self.call_center_session.call_center_steps[0]
  end
  def call_center_steps_sorted
    steps = self.call_center_session.call_center_steps
    steps.sort! do |a, b|
      a.created_at <=> b.created_at
    end
    return steps
  end
  def get_next_step(step_id, answer)    
    step = CallCenterStep.find(step_id)
    step.answer = (answer == 'Yes')
    step.save!
    new_step = nil
    engine :engine do |e|
      CallCenterRulebook.new(e, self).rules
      e.assert(step)
      e.match
      new_step = e.retrieve(CallCenterStep)
    end
    call_center_step = new_step[0]
    return call_center_step
  end
  
  def find_next_step(key)
    next_step = nil
    next_steps = []
    self.call_center_steps_sorted.each do |step|
      if step.question_key == key
        next_steps << step
      end
    end
    RAILS_DEFAULT_LOGGER.warn(next_steps.inspect)
    if !next_steps.blank?
      next_steps.each do |step|
        if step.answer.nil?
          return step
        end
      end
    end
    return nil
  end
  private
  def generate_call_center_steps
    user = self.user
    operator = User.find(operator_id)
    #create first step
	  create_call_center_step(USER_HOME_PHONE, user, operator, current_caregiver, "Call User #{self.user.name}")
	  create_call_center_step(USER_MOBILE_PHONE, user, operator)
	  #create caregiver steps
    caregivers = self.user.active_caregivers
		caregivers.each do |caregiver|
		  create_call_center_step(CAREGIVER_MOBILE_PHONE, user, operator, caregiver, "Call Caregiver ##{caregiver.position} #{caregiver.name}")
		  create_call_center_step(CAREGIVER_HOME_PHONE, user, operator, caregiver)
		  create_call_center_step(CAREGIVER_WORK_PHONE, user, operator, caregiver)
	  end
	
	  create_call_center_step(AMBULANCE, user, operator)
	  create_call_center_step(ON_BEHALF, user, operator)    
	  create_call_center_step(AGENT_CALL_911, user, operator)
	  create_call_center_step(AMBULANCE_DISPATCHED, user, operator)
	  
	  create_call_center_step(THE_END, user, operator, current_caregiver, THE_END)
  end
  def current_caregiver
    return self.user.active_caregivers[0]
  end
  def create_call_center_step(key, user, operator, caregiver=current_caregiver, header=nil)
    step = CallCenterStep.new(:call_center_session_id => self.call_center_session.id)
    step.header       = header
	  step.question_key = key
	  step.instruction  = self.user.get_instruction(key, operator, caregiver)
	  step.script       = self.user.get_script(key, operator, caregiver, self.event)
	  step.save!
	  step = nil
  end
end