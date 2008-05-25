class Email < ActiveRecord::Base
  def self.notify_by_priority
    ActionMailer::ARSendmail.run
    ActiveRecord::Base.verify_active_connections!()
  end
end
