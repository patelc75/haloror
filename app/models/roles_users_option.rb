class RolesUsersOption < ActiveRecord::Base
  acts_as_audited
  belongs_to :roles_user

  # =============
  # = callbacks =
  # =============
  
  # 
  #  Tue Dec 21 22:07:07 IST 2010, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3896
  #   * create alert_option records for this roles_user with text, email and phone attributes
  def after_save
    unless roles_user.blank?
      if ( _critical = AlertGroup.critical )
        _critical.alert_types.each do |_alert_type|
          #   * find or instantiate a row
          _alert_option = _alert_type.alert_options.find_by_roles_user_id( roles_user) # fetch existing
          #   * WARNING: do not use the rails shortcut. some error here. check console output below
          #   * user "build", then assign roles_user
          # # (rdb:1) _alert_type.alert_options.build( :roles_user_id => roles_user)
          # # #<AlertOption id: nil, roles_user_id: 1, alert_type_id: 27, phone_active: nil, email_active: nil, text_active: nil, created_at: nil, updated_at: nil>
          # # (rdb:1) roles_user
          # # #<RolesUser id: 3534, user_id: 3568, role_id: 3357, created_at: "2010-12-21 17:18:25", updated_at: "2010-12-21 17:18:25">
          _alert_option ||= _alert_type.alert_options.build # ( :roles_user_id => roles_user) # not found? build new
          _alert_option.roles_user   = roles_user
          #   * update all 3 attributes from self
          _alert_option.email_active = email_active
          _alert_option.phone_active = phone_active
          _alert_option.text_active  = text_active
          #   * code below is not working somehow. need all assignments explicitly, not dynamically
          # ["phone_active", "email_active", "text_active"].each do |_attribute|
          #   #   * fetch from self
          #   #   * assign to _alert_option
          #   _alert_option.send( "#{_attribute}=".to_sym, self.send("#{_attribute}"))
          # end
          _alert_option.save
        end # loop
      end # "critical" found
    end # roles_user missing?
  end

  # ==================
  # = public methods =
  # ==================

  # 
  #  Tue Dec 21 22:06:02 IST 2010, ramonrails
  #   * TODO: DRY:
  # roles_user.user unless roles_user.blank?
  def owner_user # for auditing
    self.roles_user.user
  rescue
    nil
  end
  
end
