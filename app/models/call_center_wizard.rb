require 'ruleby'
class CallCenterWizard < ActiveRecord::Base
  belongs_to :call_center_session
  belongs_to :event
  belongs_to :user
  
  after_create :generate_call_center_steps
  attr_reader :previous_wizard
  
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
  THANK_YOU_PRE_AGENT_CALL_911 = "Thank You, Pre Agent Call 911"
  PRE_AGENT_CALL_911    = "PRE Agent Call 911"
  AGENT_CALL_911        = "Agent Call 911" 
  AMBULANCE_DISPATCHED  = "Ambulance Dispatched"
  THE_END               = "Resolve the Event"
  CAREGIVER_GOOD_BYE    = "Caregiver Good Bye."
  USER_GOOD_BYE         = "User Good Bye."
  RECONTACT_USER       = "Recontact User?"      
  RECONTACT_USER_OK = "Recontact User OK."
  RECONTACT_USER_ABLE_TO_RESET = "User Able to Reset."
  RECONTACT_USER_NOT_ABLE_TO_RESET = "User Not Able to Reset."
  RECONTACT_USER_NOT_ABLE_TO_RESET_CONTINUE = "User Not Able to Reset Continue"
  RECONTACT_CAREGIVER  = "Recontact Caregiver?"
  RECONTACT_CAREGIVER_ACCEPT_RESPONSIBILITY = "Recontact Accept Responsibility"
  RECONTACT_CAREGIVER_ABLE_TO_RESET = "Caregiver Able to Reset Gateway."
  RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET = "Caregiver Not Able to Reset Gateway."
  RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET_CONTINUE = "Caregiver Not Able to Reset Gateway, Continue."
  
  
  include Ruleby
  def first_step()
    self.call_center_session.call_center_steps.sort! do |a, b|
      a.created_at <=> b.created_at
    end
	  step = self.call_center_session.call_center_steps[0]
	  if step.script.nil?
	    return get_next_step(step.id, false)
	  else
	    return step
	  end
  end
  def call_center_steps_sorted
    steps = self.call_center_session.call_center_steps
    steps.sort! do |a, b|
      a.created_at <=> b.created_at
    end
    return steps
  end
  def get_next_step(step_id, answer) 
    if event.event_type == CallCenterFollowUp.class_name 
      ccf = CallCenterFollowUp.find(event.event_id)
      @previous_wizard = CallCenterWizard.find_by_event_id(ccf.event.id)  
    end
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
    if event.event_type == CallCenterFollowUp.class_name 
      ccf = CallCenterFollowUp.find(event.event_id)
      @previous_wizard = CallCenterWizard.find_by_event_id(ccf.event.id)  
    end
    next_step = nil
    next_steps = []
    self.call_center_steps_sorted.each do |step|
       RAILS_DEFAULT_LOGGER.warn("#{step.question_key} #{step.user_id} #{key} #{user_id}")
      if step.question_key == key && step.user_id == user_id
        next_steps << step
      end
    end
     RAILS_DEFAULT_LOGGER.warn("next_steps:  #{next_steps.inspect}")
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
  
  def was_user_contacted?
    self.call_center_steps_sorted.each do |step|
      if step.question_key == USER_HOME_PHONE && step.answer == true
        return true
      elsif step.question_key == USER_MOBILE_PHONE && step.answer == true
        return true
      end
    end
    return false
  end
  
  def last_caregiver_contacted
    self.call_center_steps_sorted.each do |step|
      if step.question_key == CAREGIVER_ACCEPT_RESPONSIBILITY && step.answer == true
        return User.find(step.user_id)
      end
    end
    return nil
  end
  private
  def generate_call_center_steps
    user = self.user
    operator = User.find(operator_id)
    user_contacted = false
    last_caregiver_contacted = nil
    if event.event_type == CallCenterFollowUp.class_name
      ccf = CallCenterFollowUp.find(event.event_id)
      @previous_wizard = CallCenterWizard.find_by_event_id(ccf.event.id)
      user_contacted = @previous_wizard.was_user_contacted?
      last_caregiver_contacted = @previous_wizard.last_caregiver_contacted
      
        #create call center step to recontact the user
      	    create_call_center_step(USER_HOME_PHONE, user, operator, "Notes for User #{self.user.name}")
      	    create_call_center_step(USER_MOBILE_PHONE, user, operator, "Notes for User #{self.user.name}")
        create_call_center_step(RECONTACT_USER, user, operator, "Notes for User #{self.user.name}")
    	  create_call_center_step(RECONTACT_USER_OK, user, operator, "Notes for User #{self.user.name}")
    	  create_call_center_step(RECONTACT_USER_ABLE_TO_RESET, user, operator, "Notes for User #{self.user.name}")
    	  create_call_center_step(RECONTACT_USER_NOT_ABLE_TO_RESET, user, operator, "Notes for User #{self.user.name}")
    	  create_call_center_step(RECONTACT_USER_NOT_ABLE_TO_RESET_CONTINUE, user, operator, "Notes for User #{self.user.name}")
      if last_caregiver_contacted
        #create call center step to recontact the caregiver
        str = "Notes for Caregiver #1 #{last_caregiver_contacted.name}"
		      create_caregiver_call_center_step(last_caregiver_contacted, CAREGIVER_MOBILE_PHONE, user, operator, str)
		      create_caregiver_call_center_step(last_caregiver_contacted, CAREGIVER_HOME_PHONE, user, operator, str)
		      create_caregiver_call_center_step(last_caregiver_contacted, CAREGIVER_WORK_PHONE, user, operator, str)
        create_caregiver_call_center_step(last_caregiver_contacted, RECONTACT_CAREGIVER, user, operator, str)
	      create_caregiver_call_center_step(last_caregiver_contacted, RECONTACT_CAREGIVER_ACCEPT_RESPONSIBILITY, user, operator, str)
    	  create_caregiver_call_center_step(last_caregiver_contacted, RECONTACT_CAREGIVER_ABLE_TO_RESET, user, operator, str)
    	  create_caregiver_call_center_step(last_caregiver_contacted, RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET, user, operator, str)
    	  create_caregiver_call_center_step(last_caregiver_contacted, RECONTACT_CAREGIVER_NOT_ABLE_TO_RESET_CONTINUE, user, operator, str)
      end
      caregivers = self.user.active_caregivers
      cgs = []
      caregivers.each do |caregiver|
        unless last_caregiver_contacted && last_caregiver_contacted.id == caregiver.id
          cgs << caregiver
        end
      end
      caregivers = cgs
		  caregivers.each do |caregiver|
		    strike = false
		    if !user.has_phone? caregiver, 'Caregiver'
		      strike = true
		    end
		    str = nil
		    if strike
		      str = "<del>Notes for Caregiver ##{caregiver.position} #{caregiver.name}</del>"
	      else
	        str = "Notes for Caregiver ##{caregiver.position} #{caregiver.name}"
        end
		      create_caregiver_call_center_step(caregiver, CAREGIVER_MOBILE_PHONE, user, operator, str)
		      create_caregiver_call_center_step(caregiver, CAREGIVER_HOME_PHONE, user, operator, str)
		      create_caregiver_call_center_step(caregiver, CAREGIVER_WORK_PHONE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_ACCEPT_RESPONSIBILITY, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_THANK_YOU, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_AT_HOUSE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_GO_TO_HOUSE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, ON_BEHALF_GO_TO_HOUSE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, AMBULANCE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, ON_BEHALF, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, THANK_YOU_PRE_AGENT_CALL_911, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, PRE_AGENT_CALL_911, user, operator, str)
          create_caregiver_call_center_step(caregiver, AGENT_CALL_911, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, AMBULANCE_DISPATCHED, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_GOOD_BYE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, THE_END, user, operator, str)
  	  end
    else
   
	    create_call_center_step(USER_HOME_PHONE, user, operator, "Notes for User #{self.user.name}")
	    create_call_center_step(USER_MOBILE_PHONE, user, operator, "Notes for User #{self.user.name}")
    
	    create_call_center_step(USER_OK, user, operator, "Notes for User #{self.user.name}")
	    create_call_center_step(USER_AMBULANCE, user, operator, "Notes for User #{self.user.name}")
	    create_call_center_step(ON_BEHALF, user, operator, "Notes for User #{self.user.name}")    
	    create_call_center_step(PRE_AGENT_CALL_911, user, operator, "Notes for User #{self.user.name}")
	    create_call_center_step(AGENT_CALL_911, user, operator, "Notes for User #{self.user.name}")
	    create_call_center_step(AMBULANCE_DISPATCHED, user, operator, "Notes for User #{self.user.name}")
	    create_call_center_step(USER_GOOD_BYE, user, operator, "Notes for User #{self.user.name}")
	 
	  #create caregiver steps
	 
      caregivers = self.user.active_caregivers
		  caregivers.each do |caregiver|
		    strike = false
		    if !user.has_phone? caregiver, 'Caregiver'
		      strike = true
		    end
		    str = nil
		    if strike
		      str = "<del>Notes for Caregiver ##{caregiver.position} #{caregiver.name}</del>"
	      else
	        str = "Notes for Caregiver ##{caregiver.position} #{caregiver.name}"
        end
		      create_caregiver_call_center_step(caregiver, CAREGIVER_MOBILE_PHONE, user, operator, str)
		      create_caregiver_call_center_step(caregiver, CAREGIVER_HOME_PHONE, user, operator, str)
		      create_caregiver_call_center_step(caregiver, CAREGIVER_WORK_PHONE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_ACCEPT_RESPONSIBILITY, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_THANK_YOU, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_AT_HOUSE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_GO_TO_HOUSE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, ON_BEHALF_GO_TO_HOUSE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, AMBULANCE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, ON_BEHALF, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, THANK_YOU_PRE_AGENT_CALL_911, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, PRE_AGENT_CALL_911, user, operator, str)
          create_caregiver_call_center_step(caregiver, AGENT_CALL_911, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, AMBULANCE_DISPATCHED, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, CAREGIVER_GOOD_BYE, user, operator, str)
    	    create_caregiver_call_center_step(caregiver, THE_END, user, operator, str)
  	  end
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