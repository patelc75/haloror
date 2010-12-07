class Battery < Vital  
  set_table_name "batteries"
  belongs_to :device
  has_many :users, :class_name => "User", :foreign_key => "last_battery_id"
  
  #
  #  Wed Dec  8 00:52:21 IST 2010, ramonrails
  #   * switched off for 1.6.0 www issues
   # cache trigger
  # # saves the latest battery status in users table
  # def after_save
  #   if (user = User.find(user_id))
  #     user.last_battery_id = id
  #     user.send(:update_without_callbacks) # quick fix to https://redmine.corp.halomonitor.com/issues/3067
  #   end
  #   # User.update(user_id, {:last_battery_id => id})
  # end
  
  def self.get_average(condition)
    Battery.average(:percentage, :conditions => condition)
  end
end