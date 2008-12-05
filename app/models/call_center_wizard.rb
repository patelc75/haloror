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
  USER_AMBULANCE             = "Ambulance Needed?"
  USER_OK               = "IS USER OK?"
  AMBULANCE             = "NON-Ambulance Needed?" 
  CAREGIVER_ACCEPT_RESPONSIBILITY     = "Caregiver, IS USER OK?" 
  CAREGIVER_THANK_YOU   = "THANK YOU"
  CAREGIVER_AT_HOUSE    = "At House?"
  CAREGIVER_GO_TO_HOUSE = "Caregiver, go to user house?" 
  ON_BEHALF_GO_TO_HOUSE = "Ask if they will call 911 from user's house on behalf of halouser?"        
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
  
  def find_next_step(key, user_id)
    next_step = nil
    next_steps = []
    self.call_center_steps_sorted.each do |step|
      # RAILS_DEFAULT_LOGGER.warn("#{step.question_key} #{step.user_id} #{key} #{user_id}")
      if step.question_key == key && step.user_id == user_id
        next_steps << step
      end
    end
    # RAILS_DEFAULT_LOGGER.warn("next_steps:  #{next_steps.inspect}")
    if !next_steps.blank?
      next_steps.each do |step|
        if step.answer.nil? 
          if step.script.nil?
            return get_next_step(step.id, false)
          else
            return step
          end
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
	  create_call_center_step(USER_HOME_PHONE, user, operator, "Notes for User #{self.user.name}")
	  create_call_center_step(USER_MOBILE_PHONE, user, operator, "Notes for User #{self.user.name}")
	  create_call_center_step(USER_OK, user, operator, "Notes for User #{self.user.name}")
	  create_call_center_step(USER_AMBULANCE, user, operator, "Notes for User #{self.user.name}")
	  create_call_center_step(ON_BEHALF, user, operator, "Notes for User #{self.user.name}")    
	  create_call_center_step(AGENT_CALL_911, user, operator, "Notes for User #{self.user.name}")
	  create_call_center_step(AMBULANCE_DISPATCHED, user, operator, "Notes for User #{self.user.name}")
	  #create caregiver steps
    caregivers = self.user.active_caregivers
		caregivers.each do |caregiver|
		    create_caregiver_call_center_step(caregiver, CAREGIVER_MOBILE_PHONE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
		    create_caregiver_call_center_step(caregiver, CAREGIVER_HOME_PHONE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
		    create_caregiver_call_center_step(caregiver, CAREGIVER_WORK_PHONE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, CAREGIVER_ACCEPT_RESPONSIBILITY, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, CAREGIVER_THANK_YOU, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, CAREGIVER_AT_HOUSE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, CAREGIVER_GO_TO_HOUSE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, ON_BEHALF_GO_TO_HOUSE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, AMBULANCE, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, ON_BEHALF, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, AGENT_CALL_911, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, AMBULANCE_DISPATCHED, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
    	  create_caregiver_call_center_step(caregiver, THE_END, user, operator, "Notes for Caregiver ##{caregiver.position} #{caregiver.name}")
	  end
	
	  
	  create_call_center_step(THE_END, user, operator)
	  
  end
  def create_caregiver_call_center_step(caregiver, key, user, operator, header=nil)
    step = CallCenterStep.new(:call_center_session_id => self.call_center_session.id)
    step.user_id      = caregiver.id
    step.header       = header
	  step.question_key = key
    step.instruction  = self.user.get_cg_instruction(key, operator, caregiver)
	  step.script       = self.user.get_cg_script(key, operator, caregiver, self.event)
	  step.save!
	  step = nil
  end
  def create_call_center_step(key, user, operator, header=nil)
    step = CallCenterStep.new(:call_center_session_id => self.call_center_session.id)
    step.user_id      = user.id
    step.header       = header
	  step.question_key = key
    step.instruction  = self.user.get_instruction(key, operator)
	  step.script       = self.user.get_script(key, operator, self.event)
	  step.save!
	  step = nil
  end
end