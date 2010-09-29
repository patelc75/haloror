class AddDemoModeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :demo_mode, :boolean
    #
    # update existing data for this migration
    User.all.each {|e| e.set_demo_mode( false) } # will also :update_without_callbacks
  end

  def self.down
    remove_column :users, :demo_mode
  end
end
