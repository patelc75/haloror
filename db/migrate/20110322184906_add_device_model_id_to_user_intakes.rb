# 
#  Wed Mar 23 00:20:22 IST 2011, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/4291
class AddDeviceModelIdToUserIntakes < ActiveRecord::Migration
  def self.up
    add_column :user_intakes, :device_model_id, :integer
    add_column :user_intakes, :device_model_size, :string
  end

  def self.down
    remove_column :user_intakes, :device_model_id
    remove_column :user_intakes, :device_model_size
  end
end
