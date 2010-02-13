class Carrier < ActiveRecord::Base
  has_many :profiles
  named_scope :ordered, :order => :name
end
