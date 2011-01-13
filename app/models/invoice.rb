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
