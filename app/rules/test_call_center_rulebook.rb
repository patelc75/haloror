# require 'rubygems'
# # require 'ruleby'
# # require 'call_center_rulebook'
# class TestCallCenterRulebook
#   # include Ruleby
#   def run
#     new_step = nil
#     engine :engine do |e|
#       CallCenterRulebook.new(e).rules
#       step = CallCenterStep.create( :call_center_steps_group_id   => 1,
#                                     :question_key                => "Home Phone Answered?",
#                                     :answer                      => true,
#                                     :header                      => "Call User")
#       e.assert(step)
#       e.match
#       new_step = e.retrieve(CallCenterStep)
#     end  
#     puts new_step.inspect
#     return new_step
#   end
# end