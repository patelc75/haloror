class CallCenterDeferred < DeviceAlert
  set_table_name "call_center_deferreds"

  belongs_to :device
  belongs_to :user
  belongs_to :event
  belongs_to :call_center_session
  def after_save
    Event.create_event(self.user_id, CallCenterDeferred.class_name, self.id, self.timestamp)
  end
end