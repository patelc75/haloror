class Email < ActiveRecord::Base
  def self.notify_by_priority
      RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority running at #{Time.now}")
      arsendmail = ActionMailer::ARSendmail.new(:Once => true)
      arsendmail.run
  end
end
