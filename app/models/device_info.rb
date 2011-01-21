class DeviceInfo < ActiveRecord::Base
  belongs_to :device
  belongs_to :mgmt_response
  belongs_to :device_info, :polymorphic => true
  
  # ============
  # = triggers =
  # ============
  
  def before_save
    #   * create a new column software_version_new (boolean) in device_infos table and set it to true
    #   * TRUE only when version changes
    self.software_version_new = version_changed?
    #   * create a new column software_version_current (boolean) in device_infos table and set it to true
    #   * TRUE in all cases
    #   * Required for simpler SQLs
    self.software_version_current = true
  end
  
  #   * this triggers only after the current-row is successfully saved
  def after_save
    update_previous_as_non_current
  end
  
  def after_create
    update_previous_as_non_current
  end
  
  # ===========================
  # = public instance methods =
  # ===========================
  
  #   * If software_version is different from the software_version in the most recent previous device_info row (sort by created_at for the same device_id)
  def version_changed?
    previous_row.blank? || (software_version != previous_row.software_version)
  end
  
  def previous_row
    if @previous_row.blank?
      @previous_row = if self.new_record?
        DeviceInfo.first( :conditions => { :device_id => device_id }, :order => 'created_at DESC')
      else
        DeviceInfo.first( :conditions => ["device_id = ? AND id <> ?", device_id, id], :order => 'created_at DESC')
      end
    else
      @previous_row
    end
  end
  
  # ===================
  # = private methods =
  # ===================
  
  def update_previous_as_non_current
    #   * set previous row software_version_current to false
    #   * required for simpler SQLs
    #   * Only ONE row can have this TRUE for each DEVICE
    #   * previous row always is marked non-current, whether version changes or not
    _row = previous_row
    _row.software_version_current = false
    _row.send( :update_without_callbacks)
  end
end
