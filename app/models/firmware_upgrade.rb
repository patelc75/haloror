class FirmwareUpgrade < ActiveRecord::Base
  belongs_to :ftp
  has_many :mgmt_cmds, :as => :cmd
  
  # triggers ----------------------
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  #   Firmware upgrade record must have a date
  def before_save
    date_added ||= Date.today # mark today's date unless assigned already to the object
  end
  
  # class methods ---------------------
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def self.current_software_version
    # WARNING: check business logic here. Needs a check
    #   Assumption: latest ID is the most recent and current firmware record
    # Actual firmware version acn be anything, we are checking the latest record in database
    # if devices need to use an earlier version as "current version", a new entry can be added
    # this will also keep track of version changes made to devices
    self.count.zero? ? "" : first( :order => "id DESC").version
  end
  
  # instance methods -------------------
  
  # https://redmine.corp.halomonitor.com/issues/3159
  # WARNING: needs test coverage
  def current_version?
    version == FirmwareUpgrade.current_software_version
  end
end
