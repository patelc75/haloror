class AddCancelledAtToUsers < ActiveRecord::Migration
  def self.up
    # 
    #  Thu Dec 30 23:15:11 IST 2010, ramonrails
    #   * https://redmine.corp.halomonitor.com/issues/3950
    add_column :users, :cancelled_at, :datetime
  end

  def self.down
    remove_column :users, :cancelled_at
  end
end
