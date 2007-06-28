class RawDataFile < ActiveRecord::Base
  #this is like a constructor
  has_attachment  :storage => :file_system, 
                  :size => 0.megabyte..2.megabytes

  #validates_as_attachment ensures that size, content_type and filename are present 
  #and checks against the options given to has_attachment; in our case the original 
  #should be no larger than 1 megabyte.
  validates_as_attachment # ok two lines if you want to do validation, and why wouldn't you?
end
