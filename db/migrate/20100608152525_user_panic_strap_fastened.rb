class UserPanicStrapFastened < ActiveRecord::Migration
  def self.up
    remove_column :users, :has_no_panic_button_test
    remove_column :users, :has_no_strap_detected
    remove_column :users, :has_no_call_center_account
    add_column :users, :last_panic_id, :integer
    add_column :users, :last_strap_fastened_id, :integer
  end

  def self.down
    remove_column :users, :last_panic_id
    remove_column :users, :last_strap_fastened_id
  end
end
