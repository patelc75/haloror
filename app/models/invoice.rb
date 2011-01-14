class Invoice < ActiveRecord::Base
  belongs_to :user
  belongs_to :affiliate_fee_group, :class_name => "Group"
  belongs_to :referral_group, :class_name => "Group"
  
  validates_presence_of :user_id, :on => :create, :message => "can't be blank"
  
  named_scope :ordered, :order => "created_at DESC"
  
  # ===========================
  # = public instance methods =
  # ===========================
  
  def user_name
    user.blank? ? '' : user.name
  end
  
  # 
  #  Sat Jan 15 00:15:21 IST 2011, ramonrails
  #   * groups where user is a member
  def user_groups
    user.group_memberships unless user.blank?
  end
  
  # 
  #  Sat Jan 15 01:16:03 IST 2011, ramonrails
  #   * group names in more sensible format
  def group_names
    _names = user_groups.collect(&:name).compact.uniq.sort
    (_names.length > 1) ? "#{_names.first}<span class='tiny'>... #{_names.length - 1} more</span>" : _names.join(', ')
  end

  # 
  #  Sat Jan 15 02:32:45 IST 2011, ramonrails
  #   * user table > cancelled_at
  def cancelled_date
    user.cancelled_at unless user.blank?
  end
  
  # 
  #  Tue Jan 11 01:08:02 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3988
  def affiliate_fee_group_name
    affiliate_fee_group.name rescue ''
  end

  # 
  #  Tue Jan 11 01:08:02 IST 2011, ramonrails
  #   * https://redmine.corp.halomonitor.com/issues/3988
  def referral_group_name
    referral_group.name rescue ''
  end

end
