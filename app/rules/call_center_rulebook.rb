require 'ruleby'
class CallCenterRulebook < Ruleby::Rulebook
  def initialize(eng, wizard)
    super(eng)
    @wizard = wizard
  end
  def rules
    create_call_center_step_rule(CallCenterWizard::USER_HOME_PHONE,      true,   CallCenterWizard::USER_AMBULANCE)
    create_call_center_step_rule(CallCenterWizard::USER_HOME_PHONE,      false,  CallCenterWizard::USER_MOBILE_PHONE)
    create_call_center_step_rule(CallCenterWizard::USER_MOBILE_PHONE,    true,   CallCenterWizard::USER_AMBULANCE)
    create_call_center_step_rule(CallCenterWizard::USER_MOBILE_PHONE,    false,  CallCenterWizard::CAREGIVER_MOBILE_PHONE)
    create_call_center_step_rule(CallCenterWizard::CAREGIVER_MOBILE_PHONE, true,   CallCenterWizard::AMBULANCE)
    create_call_center_step_rule(CallCenterWizard::CAREGIVER_MOBILE_PHONE, false,  CallCenterWizard::CAREGIVER_HOME_PHONE)
    create_call_center_step_rule(CallCenterWizard::CAREGIVER_HOME_PHONE, true,   CallCenterWizard::AMBULANCE)
    create_call_center_step_rule(CallCenterWizard::CAREGIVER_HOME_PHONE, false,  CallCenterWizard::CAREGIVER_WORK_PHONE)
    create_call_center_step_rule(CallCenterWizard::CAREGIVER_WORK_PHONE, true,   CallCenterWizard::AMBULANCE)
    create_call_center_step_rule(CallCenterWizard::CAREGIVER_WORK_PHONE, false,  CallCenterWizard::CAREGIVER_MOBILE_PHONE)
    create_call_center_step_rule(CallCenterWizard::AMBULANCE,            true,   CallCenterWizard::ON_BEHALF)
    create_call_center_step_rule(CallCenterWizard::AMBULANCE,            false,  CallCenterWizard::THE_END)
    create_call_center_step_rule(CallCenterWizard::USER_AMBULANCE,            true,   CallCenterWizard::AGENT_CALL_911)
    create_call_center_step_rule(CallCenterWizard::USER_AMBULANCE,            false,  CallCenterWizard::THE_END)
    create_call_center_step_rule(CallCenterWizard::ON_BEHALF,            true,   CallCenterWizard::AMBULANCE_DISPATCHED)
    create_call_center_step_rule(CallCenterWizard::ON_BEHALF,            false,  CallCenterWizard::AGENT_CALL_911)
    create_call_center_step_rule(CallCenterWizard::AGENT_CALL_911,       true,   CallCenterWizard::THE_END)
    create_call_center_step_rule(CallCenterWizard::AMBULANCE_DISPATCHED, true,   CallCenterWizard::THE_END)
    create_call_center_step_rule(CallCenterWizard::THE_END, true, CallCenterWizard::THE_END)
    create_call_center_step_rule(CallCenterWizard::THE_END, false, CallCenterWizard::THE_END)
  end
  
  def create_call_center_step_rule(question_key, answer, next_question_key)
    
    rule [CallCenterStep, :step, method.question_key == question_key, method.answer == answer] do |context|
      step = context[:step]
      ccs = @wizard.find_next_step(next_question_key)
      retract(step)
      if ccs
        ccs.answer = nil
        ccs.previous_call_center_step_id = step.id
        ccs.save!
        assert(ccs) 
      end
    end
  end
end