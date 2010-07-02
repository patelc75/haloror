class UserLog < ActiveRecord::Base
  belongs_to :user
  named_scope :recent_on_top, :order => "created_at DESC"
  named_scope :few, lambda {|*args| {:limit => (args.flatten.first || 10) }}
end
