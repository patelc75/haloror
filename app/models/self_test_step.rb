class SelfTestStep < ActiveRecord::Base
  belongs_to :self_test_step_description
  belongs_to :self_test_session
end