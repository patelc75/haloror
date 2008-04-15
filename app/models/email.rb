class Email < ActiveRecord::Base
  def self.notify_by_priority
    ActionMailer::ARSendmail.run
  end
end
