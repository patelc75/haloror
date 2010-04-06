class OscopeStartMsg < ActiveRecord::Base
  has_many :oscope_msgs
  
  # callbacks
  
  # CHANGED: to prevent any situations having non-related oscope_msgs <=> oscope_start_msgs
  # https://redmine.corp.halomonitor.com/issues/2742
  # find all related oscope_msgs and link them to this once
  def after_create
    oscopes = OscopeMsg.find_all_by_timestamp_and_user_id(timestamp, user_id)
    # instantiation of oscopes already caused oscope_start_msg to link to them
    # :update_without_callbacks is a provate method. direct call will not work. need to 'send' it
    oscopes.each {|p| p.send(:update_without_callbacks) } # this will save all instantiated oscopes
  end
  
  # other methods
  
  def self.capture_reasons
    reasons = []
    OscopeStartMsg.connection.select_all('SELECT DISTINCT capture_reason from oscope_start_msgs ORDER BY capture_reason DESC').collect do |row|
      reasons << row["capture_reason"]
    end
    return reasons
  end
end