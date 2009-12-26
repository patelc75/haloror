class CreateUsersUserIntake < ActiveRecord::Migration
  def self.up
  	create_table :users_user_intakes, :id => false, :force => true do |t|
  		t.column :user_id, :integer
  		t.column :user_intake_id, :integer
  	end
  end

  def self.down
  	 drop_table :users_user_intakes
  end
end
