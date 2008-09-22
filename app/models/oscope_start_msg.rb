class OscopeStartMsg < ActiveRecord::Base
  has_many :oscope_msgs
  
  def self.capture_reasons
    reasons = []
    OscopeStartMsg.connection.select_all('SELECT DISTINCT capture_reason from oscope_start_msgs ORDER BY capture_reason DESC').collect do |row|
      reasons << row["capture_reason"]
    end
    return reasons
  end
end