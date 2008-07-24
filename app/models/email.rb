class Email < ActiveRecord::Base
  def self.notify_by_priority
    begin
      RAILS_DEFAULT_LOGGER.warn("Email.notify_by_priority running at #{Time.now}")
      arsendmail = ActionMailer::ARSendmail.new(:Once => true, :Verbose => true)
      arsendmail.run
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.warn("RESCUE called in Email.notify_by_priority #{e}")
    rescue
      RAILS_DEFAULT_LOGGER.warn("RESCUE called in Email.notify_by_priority")
    end
  end
end
