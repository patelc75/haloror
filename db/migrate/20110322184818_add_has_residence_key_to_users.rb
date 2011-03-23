# 
#  Wed Mar 23 00:20:18 IST 2011, ramonrails
#   * https://redmine.corp.halomonitor.com/issues/4291
class AddHasResidenceKeyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :has_residence_key, :boolean
  end

  def self.down
    remove_column :users, :has_residence_key
  end
end
