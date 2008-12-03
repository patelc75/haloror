require 'ruleby'
class CallCenterRulebook < Ruleby::Rulebook
  def initialize(eng, wizard)
    super(eng)
    @wizard = wizard
  end
  def rules
    caregiver_id = nil
    caregivers = @wizard.user.active_caregivers
    if caregivers
      caregiver_id = caregivers[0].id
    end
    user_id = @wizard.user.id
    create_call_center_step_rule(user_id, CallCenterWizard::USER_HOME_PHONE,      true,   CallCenterWizard::USER_AMBULANCE,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::USER_HOME_PHONE,      false,  CallCenterWizard::USER_MOBILE_PHONE,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::USER_MOBILE_PHONE,    true,   CallCenterWizard::USER_AMBULANCE,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::USER_MOBILE_PHONE,    false,  CallCenterWizard::CAREGIVER_MOBILE_PHONE,caregiver_id)
    create_call_center_step_rule(user_id, CallCenterWizard::USER_AMBULANCE,            true,   CallCenterWizard::AGENT_CALL_911,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::USER_AMBULANCE,            false,  CallCenterWizard::THE_END,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::ON_BEHALF,            true,   CallCenterWizard::AMBULANCE_DISPATCHED,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::ON_BEHALF,            false,  CallCenterWizard::AGENT_CALL_911,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::AGENT_CALL_911,       true,   CallCenterWizard::THE_END,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::AMBULANCE_DISPATCHED, true,   CallCenterWizard::THE_END,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::THE_END, true, CallCenterWizard::THE_END,user_id)
    create_call_center_step_rule(user_id, CallCenterWizard::THE_END, false, CallCenterWizard::THE_END,user_id)
    
    if caregivers
      caregivers = caregivers[1, caregivers.size - 1]
      caregivers.each do |caregiver|
        create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_MOBILE_PHONE, true,   CallCenterWizard::AMBULANCE, caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_MOBILE_PHONE, false,  CallCenterWizard::CAREGIVER_HOME_PHONE, caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_HOME_PHONE, true,   CallCenterWizard::AMBULANCE, caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_HOME_PHONE, false,  CallCenterWizard::CAREGIVER_WORK_PHONE, caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_WORK_PHONE, true,   CallCenterWizard::AMBULANCE, caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_WORK_PHONE, false,  CallCenterWizard::CAREGIVER_MOBILE_PHONE, caregiver.id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::AMBULANCE,            true,   CallCenterWizard::ON_BEHALF, caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::ON_BEHALF,            true,   CallCenterWizard::AMBULANCE_DISPATCHED,caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::ON_BEHALF,            false,  CallCenterWizard::AGENT_CALL_911,caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::AGENT_CALL_911,       true,   CallCenterWizard::THE_END,caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::AMBULANCE_DISPATCHED, true,   CallCenterWizard::THE_END,caregiver_id)
        create_call_center_step_rule(caregiver_id, CallCenterWizard::AMBULANCE,            false,  CallCenterWizard::THE_END, caregiver_id)
        create_call_center_step_rule(user_id, CallCenterWizard::THE_END, true, CallCenterWizard::THE_END,caregiver_id)
        create_call_center_step_rule(user_id, CallCenterWizard::THE_END, false, CallCenterWizard::THE_END,caregiver_id)
        caregiver_id = caregiver.id
      end
        
          create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_MOBILE_PHONE, true,   CallCenterWizard::AMBULANCE, caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_MOBILE_PHONE, false,  CallCenterWizard::CAREGIVER_HOME_PHONE, caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_HOME_PHONE, true,   CallCenterWizard::AMBULANCE, caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_HOME_PHONE, false,  CallCenterWizard::CAREGIVER_WORK_PHONE, caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_WORK_PHONE, true,   CallCenterWizard::AMBULANCE, caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::CAREGIVER_WORK_PHONE, false,  CallCenterWizard::CAREGIVER_MOBILE_PHONE, nil)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::AMBULANCE,            true,   CallCenterWizard::ON_BEHALF, caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::ON_BEHALF,            true,   CallCenterWizard::AMBULANCE_DISPATCHED,caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::ON_BEHALF,            false,  CallCenterWizard::AGENT_CALL_911,caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::AGENT_CALL_911,       true,   CallCenterWizard::THE_END,caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::AMBULANCE_DISPATCHED, true,   CallCenterWizard::THE_END,caregiver_id)
          create_call_center_step_rule(caregiver_id, CallCenterWizard::AMBULANCE,            false,  CallCenterWizard::THE_END, caregiver_id)
          create_call_center_step_rule(user_id, CallCenterWizard::THE_END, true, CallCenterWizard::THE_END,caregiver_id)
          create_call_center_step_rule(user_id, CallCenterWizard::THE_END, false, CallCenterWizard::THE_END,caregiver_id)
    end
  end
  
  def create_call_center_step_rule(user_id, question_key, answer, next_question_key, next_user_id)
    
    rule [CallCenterStep, :step, method.user_id == user_id, method.question_key == question_key, method.answer == answer] do |context|
      step = context[:step]
      ccs = @wizard.find_next_step(next_question_key, next_user_id)
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