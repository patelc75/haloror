class OscopeMsg < ActiveRecord::Base
  has_many :points
  belongs_to :oscope_start_msg
  belongs_to :oscope_stop_msg
end
