class SelfTestSession < ActiveRecord::Base
  has_many :self_test_steps
  belongs_to :user
end