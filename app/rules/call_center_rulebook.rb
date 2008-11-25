require 'ruleby'
class CallCenterRulebook < Ruleby::Rulebook
  def rules
    create_call_center_step_rule(:call_halouser_home_yes  , "Home Phone Answered?", true, "Ambulance Needed?")
    create_call_center_step_rule(:call_halouser_home_no   , "Home Phone Answered?", false, "Mobile Phone Answered?")
    create_call_center_step_rule(:ambulance_needed_yes    , "Ambulance Needed?"   , true, "Ask if they will call 911 on behalf of halouser?")
    create_call_center_step_rule(:call_911_on_behalf_yes  , "Ask if they will call 911 on behalf of halouser?", true,  "Ambulance Dispatched")
    create_call_center_step_rule(:call_911_on_behalf_no   , "Ask if they will call 911 on behalf of halouser?", false, "Agent Call 911")
    create_call_center_step_rule(:call_halouser_mobile_yes, "Mobile Phone Answered?", true, "Ambulance Needed?")
    create_call_center_step_rule(:call_halouser_mobile_no , "Mobile Phone Answered?", false, "Call Next Caregiver")
    create_call_center_step_rule(:call_caregiver_mobile_yes, "Call Next Caregiver", true, "Ambulance Needed?")
    create_call_center_step_rule(:call_caregiver_mobile_no, "Call Next Caregiver", false, "Caregiver Home Phone Answered?")
    create_call_center_step_rule(:call_caregiver_home_yes , "Caregiver Home Phone Answered?", true, "Ambulance Needed?")
    create_call_center_step_rule(:call_caregiver_home_no  , "Caregiver Home Phone Answered?", false, "Caregiver Work Phone Answered?")
    create_call_center_step_rule(:call_caregiver_work_yes , "Caregiver Work Phone Answered?", true, "Ambulance Needed?")
    create_call_center_step_rule(:call_caregiver_work_no  , "Caregiver Work Phone Answered?", false, "Another Caregiver?")
    create_call_center_step_rule(:call_another_caregiver_yes, "Another_Caregiver?", true, "Call Next Caregiver")
    create_call_center_step_rule(:call_another_caregiver_no , "Another Caregiver?", false, "Agent Call 911")
    create_call_center_step_rule(:call_agent_operator_911_yes, "Agent Call 911", true, "Ambulance Dispatched")
end
  
  def create_call_center_step_rule(name, question_key, answer, next_question_key)
    rule name, [CallCenterStep, :step, method.question_key == question_key, method.answer == answer] do |context|
      step = context[:step]
      ccs = CallCenterStep.create( :call_center_steps_group_id   => step.call_center_steps_group_id,
                                :question_key                   => next_question_key,
                                :header                         => step.header)
      retract(step)
      assert(ccs)
    end
  end
end