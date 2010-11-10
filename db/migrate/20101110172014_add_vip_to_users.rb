class AddVipToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :vip, :boolean
    #
    # update existing data for this migration
    User.all.each {|e| e.set_vip_mode( false) } # will also :update_without_callbacks
  end

  def self.down
    remove_column :users, :vip
  end
end