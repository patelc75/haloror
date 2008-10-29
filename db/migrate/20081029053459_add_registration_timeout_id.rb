class AddRegistrationTimeoutId < ActiveRecord::Migration
  def self.up
    SelfTestStepDescription.create(:description => "Registration Timed Out")
  end

  def self.down
  end
end
