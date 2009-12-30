class CreateUsersUserIntake < ActiveRecord::Migration
  def self.up
  	create_table :user_intakes_users, :id => false, :force => true do |t|
  		t.column :user_id, :integer
  		t.column :user_intake_id, :integer
  	end
  end

  def self.down
  	 drop_table :user_intakes_users
  end
end
