module Priority
  IMMEDIATE = 100 #Falls, Panics
  THRESH_HOLD = 99
  VERY_HIGH = 90
  HIGH      = 75
  MED       = 50 # all others (device alert, mgmt protocol, device data)
  LOW       = 25
  VERY_LOW  = 10 #Exception Notification
  def priority
    return MED
  end
end