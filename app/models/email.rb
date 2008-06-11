class Email < ActiveRecord::Base
  def self.notify_by_priority
    begin
      ActionMailer::ARSendmail.run
    rescue
      RAILS_DEFAULT_LOGGER.warn("RESCUE called in Email.notify_by_priority")
    end
    ActiveRecord::Base.verify_active_connections!()
  end
end
